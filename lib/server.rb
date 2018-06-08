# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'

require 'bundler/setup'
require 'hrr_rb_ssh'


def instantiate_ne logger, model, hostname, username
  klass = Class.new
  klass.class_eval File.read(File.join(".", "lib", model + ".rb"))
  ne_instance = klass.new logger, hostname, username
  begin
    ne_instance.instance_eval File.read(File.join(".", "lib", hostname + ".rb"))
  rescue Errno::ENOENT
    Thread.pass
  end
  ne_instance
end


def ne_cli_sim ne, logger=nil
  HrrRbSsh::Logger.initialize logger

  auth_password = HrrRbSsh::Authentication::Authenticator.new { |context|
    context.verify ne['username'], ne['password']
  }

  conn_ne_cli = HrrRbSsh::Connection::RequestHandler.new { |context|
    context.chain_proc { |chain|
      begin
        ne_instance = instantiate_ne(logger, ne['model'], ne['hostname'], ne['username'])
        context.io[1].write ne_instance.prompt
        loop do
          break if ne_instance.closed?
          input_str = context.io[0].readpartial(10240)
          context.io[1].write ne_instance.run(input_str)
        end
        exitstatus = 0
      rescue => e
        logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        exitstatus = 1
      end
      exitstatus
    }
  }

  options = {}
  options['authentication_password_authenticator'] = auth_password
  options['connection_channel_request_shell']      = conn_ne_cli

  server = TCPServer.new ne['ip_address'], ne['port']
  loop do
    Thread.new(server.accept) do |io|
      begin
        pid = fork do
          begin
            server = HrrRbSsh::Server.new io, options
            server.start
          rescue => e
            logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join } if logger
            exit false
          end
        end
        logger.info { "process #{pid} started" } if logger
        io.close rescue nil
        pid, status = Process.waitpid2 pid
      rescue => e
        logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join } if logger
      ensure
        status ||= nil
        logger.info { "process #{pid} finished with status #{status.inspect}" } if logger
      end
    end
  end
end
