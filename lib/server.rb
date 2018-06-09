# coding: utf-8
# vim: et ts=2 sw=2

require 'bundler/setup'
require 'hrr_rb_ssh'
require 'fileutils'
require 'logger'
require 'socket'


def instantiate_ne ne, logger
  logger.info { "Load model: #{ne['model']}" }
  klass = Class.new
  klass.class_eval File.read(File.join(File.expand_path(File.dirname(__FILE__)), ne['model'] + ".rb"))
  klass.class_eval do
    def singleton_method_added method
      @logger.info { "override method: #{method}" }
    end
  end
  ne_instance = klass.new ne['hostname'], ne['username'], logger
  begin
    logger.info { "Load host specific behavior: #{ne['hostname']}" }
    ne_instance.instance_eval File.read(File.join(File.expand_path(File.dirname(__FILE__)), ne['hostname'] + ".rb"))
  rescue Errno::ENOENT
    logger.info { "Load failed. No override" }
  end
  ne_instance
end

def auth_password ne
  HrrRbSsh::Authentication::Authenticator.new { |context|
    context.verify ne['username'], ne['password']
  }
end

def conn_cli ne
  HrrRbSsh::Connection::RequestHandler.new { |context|
    context.chain_proc { |chain|
      log_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'log', 'ne')
      log_file = File.join(log_dir, "#{ne['hostname']}.cli.log")
      log_shift_age = 0
      log_shift_size = 1048576
      FileUtils.mkdir_p(log_dir)
      logger = ::Logger.new(log_file, log_shift_age, log_shift_size)
      logger.level = ::Logger::INFO

      begin
        ne_instance = instantiate_ne(ne, logger)
        logger.info { "send:    #{ne_instance.prompt.inspect}" }
        context.io[1].write ne_instance.prompt
        loop do
          if ne_instance.closed?
            logger.info { "closed and exit" }
            break
          end
          input_str = context.io[0].readpartial(10240)
          logger.info { "receive: #{input_str.inspect}" }
          output_str = ne_instance.run(input_str)
          logger.info { "send:    #{output_str.inspect}" }
          context.io[1].write output_str
        end
        exitstatus = 0
      rescue => e
        logger.error([e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join)
        exitstatus = 1
      end
      exitstatus
    }
  }
end

def start_server ne
  log_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'log', 'ne')
  log_file = File.join(log_dir, "#{ne['hostname']}.ssh.log")
  log_shift_age = 0
  log_shift_size = 1048576
  FileUtils.mkdir_p(log_dir)
  logger = ::Logger.new(log_file, log_shift_age, log_shift_size)
  logger.level = ::Logger::INFO

  begin
    server = TCPServer.new ne['ip_address'], ne['port']
    logger.info { "Started TCP server #{server.inspect}" }
    loop do
      Thread.new(server.accept) do |io|
        logger.info { "Accepted TCP connection from #{io.peeraddr.inspect}" }
        begin
          pid = fork do
            begin
              options = {
                'authentication_password_authenticator' => auth_password(ne),
                'connection_channel_request_shell'      => conn_cli(ne),
              }
              HrrRbSsh::Logger.initialize logger
              HrrRbSsh::Server.new(io, options).start
            rescue => e
              logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              exit false
            end
          end
          logger.info { "process #{pid} started" }
          io.close rescue nil
          pid, status = Process.waitpid2 pid
        rescue => e
          logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        ensure
          status ||= nil
          logger.info { "process #{pid} finished with status #{status.inspect}" }
        end
      end
    end
  rescue => e
    logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
  end
end


def ne_cli_sim nes
  log_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'log')
  log_file = File.join(log_dir, 'ne_cli_sim.log')
  log_shift_age = 0
  log_shift_size = 1048576
  FileUtils.mkdir_p(log_dir)
  logger = ::Logger.new(log_file, log_shift_age, log_shift_size)
  logger.level = ::Logger::INFO

  ts = []
  nes.each{ |ne|
    logger.info { "Binding #{ne['hostname']}(#{ne['model']}) to #{ne['username']}@#{ne['ip_address']}:#{ne['port']}" }
    begin
      ts.push(Thread.new{ start_server ne })
    rescue => e
      logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
    end
  }
  ts.each(&:join)
end
