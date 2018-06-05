# coding: utf-8
# vim: et ts=2 sw=2

class NokiaSr
  def initialize logger, hostname, username
    @logger         = logger
    @hostname       = hostname
    @username       = username
    @prompt_history = []
    @prompt_first   = 'A:'
    @prompt_last    = '# '
    @closed         = false
    @line_buffer    = StringIO.new
  end

  def close
    @closed = true
  end

  def closed?
    @closed
  end

  def prompt
    @prompt_first + ([@hostname] + @prompt_history).join('>') + @prompt_last
  end

  def run input_str
    ret = StringIO.new

    input_lines   = input_str.scan(/.*?(?:\r\n|\r|\n)/)
    command_lines = (@line_buffer.string + input_str).scan(/.*?(?:\r\n|\r|\n)/)

    command_lines.zip(input_lines).each{ |command_line, input_line|
      ret.write (input_line.chomp + "\r\n")
      begin
        command = command_line.chomp
        command_splitted = command.split(' ')
        if command_splitted.any?
          method = command_splitted[0].gsub('-', '_')
          args = command_splitted[1..-1]
          ret.write send(method.to_sym, args)
        end
      rescue => e
        if @logger
          @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        end
        position = prompt.length
        ret.write ' '*position + '^' + "\r\n" + 'Error: Bad command.' + "\r\n"
      ensure
        ret.write prompt
      end
    }

    ret.write input_str.match(/(?:.*?(?:\r\n|\r|\n))*(.*)/)[1]

    next_line_buffer = (@line_buffer.string + input_str).match(/(?:.*?(?:\r\n|\r|\n))*(.*)/)[1]
    @line_buffer.rewind
    @line_buffer.truncate(0)
    @line_buffer.write next_line_buffer

    return ret.string
  end

  def logout args=[]
    @prompt_first   = ''
    @hostname       = ''
    @prompt_history = []
    @prompt_last    = ''
    @closed = true
    ''
  end

  def exit args=[]
    if args.size > 0 && args[0] == 'all'
      @prompt_history = []
    else
      if @prompt_history.any?
        @prompt_history.pop
      end
    end
    return ''
  end

  def action args=[]
    return ''
  end

  def address args=[]
    return ''
  end

  def admin args=[]
    if args.size > 0 && args[0] == 'display-config'
      ret = ''
    elsif args.size > 0 && args[0] == 'save'
      ret = ''
      ret += "Writing configuration to cf3:\\config.cfg\r\n"
      ret += "Saving configuration ... OK\r\n"
      ret += "Completed.\r\n"
    else
      ret = ''
    end
    return ret
  end

  def assignment args=[]
    return ''
  end

  def configure args=[]
    @prompt_history.append('config')
    return ''
  end

  def customer args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('cust')
    else
      Thread.pass
    end
    return ''
  end

  def default_action args=[]
    return ''
  end

  def def_mesh_vc_id args=[]
    return ''
  end

  def description args=[]
    return ''
  end

  def disable_learning args=[]
    return ''
  end

  def dst_ip args=[]
    return ''
  end

  def dst_port args=[]
    return ''
  end

  def egress args=[]
    @prompt_history.append('egress')
    return ''
  end

  def embed_filter args=[]
    return ''
  end

  def entry args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('entry')
    else
      Thread.pass
    end
    return ''
  end

  def environment args=[]
    ret = ''
    return ret
  end

  def eth_cfm args=[]
    @prompt_history.append('eth-cfm')
    return ''
  end

  def fdb_table_size args=[]
    return ''
  end

  def filter args=[]
    @prompt_history.append('filter')
    return ''
  end

  def force_vlan_vc_forwarding args=[]
    return ''
  end

  def igmp_snooping args=[]
    @prompt_history.append('igmp-snooping')
    return ''
  end

  def ingress args=[]
    @prompt_history.append('ingress')
    return ''
  end

  def interface args=[]
    @prompt_history.append('interface')
    return ''
  end

  def ip_filter args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('ip-filter')
    else
      Thread.pass
    end
    return ''
  end

  def lag_link_map_profile args=[]
    return ''
  end

  def mac_filter args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('mac-filter')
    else
      Thread.pass
    end
    return ''
  end

  def mac_move args=[]
    @prompt_history.append('mac-move')
    return ''
  end

  def match args=[]
    @prompt_history.append('match')
    return ''
  end

  def mesh_sdp args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('mesh-sdp')
    else
      Thread.pass
    end
    return ''
  end

  def multi_service_site args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('multi-service-site')
    else
      Thread.pass
    end
    return ''
  end

  def no args=[]
    return ''
  end

  def port args=[]
    @prompt_history.append('port')
    return ''
  end

  def qos args=[]
    return ''
  end

  def sap args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('sap')
    else
      Thread.pass
    end
    return ''
  end

  def scheduler_policy args=[]
    return ''
  end

  def sdp args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('sdp')
    else
      Thread.pass
    end
    return ''
  end

  def send_flush_on_failure args=[]
    return ''
  end

  def service args=[]
    @prompt_history.append('service')
    return ''
  end

  def service_mtu args=[]
    return ''
  end

  def show args=[]
    if args.size > 0 && args[0] == 'version'
      ret = ''
      ret += "TiMOS-C-12.0.R3 cpm/hops64 ALCATEL SR 7750 Copyright (c) 2000-2014 Alcatel-Lucent.\r\n"
      ret += "All rights reserved. All use subject to applicable license agreements.\r\n"
      ret += "Built on Tue May 20 13:37:10 PDT 2014 by builder in /rel12.0/b1/R3/panos/main\r\n"
    else
      ret = ''
    end
    return ret
  end

  def shutdown args=[]
    return ''
  end

  def split_horizon_group args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('split-horizon-group')
    else
      Thread.pass
    end
    return ''
  end

  def src_ip args=[]
    return ''
  end

  def src_port args=[]
    return ''
  end

  def src_mac args=[]
    return ''
  end

  def stp args=[]
    @prompt_history.append('stp')
    return ''
  end

  def vpls args=[]
    if args.size > 0 && args[-1] == 'create'
      @prompt_history.append('vpls')
    else
      Thread.pass
    end
    return ''
  end
end
