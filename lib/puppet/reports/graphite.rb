require 'puppet'
require 'yaml'
require 'socket'
require 'time'

Puppet::Reports.register_report(:graphite) do

  configfile = File.join([File.dirname(Puppet.settings[:config]), "graphite.yaml"])
  raise(Puppet::ParseError, "Graphite report config file #{configfile} not readable") unless File.exist?(configfile)
  config = YAML.load_file(configfile)

  GRAPHITE_SERVER                  = config[:graphite_server]
  GRAPHITE_PORT                    = config[:graphite_port]
  GRAPHITE_PREFIX                  = config[:graphite_prefix]
  GRAPHITE_USE_FQDN_TREE           = config[:use_fqdn_tree]
  GRAPHITE_APPEND_PUPPET_TO_PREFIX = config[:append_puppet_to_prefix]

  raise(Puppet::ParseError, "Graphite config must include 'graphite_server'") unless GRAPHITE_SERVER
  raise(Puppet::ParseError, "Graphite config must include 'graphite_port'")   unless GRAPHITE_PORT
  raise(Puppet::ParseError, "graphite_port must be a number") unless GRAPHITE_PORT.to_s.strip =~ /^\d+$/

  desc <<-DESC
  Send notification of failed reports to a Graphite server via socket.
  DESC

  def convert_to_bool(obj)
    return false if obj.nil?
    
    if ['true', 'yes', '1', 'y'].include?(obj.to_s.downcase)
      return true
    elsif ['false', 'no', '0', 'n'].include?(obj.to_s.downcase)
      return false
    else
      raise(Puppet::ParseError, "Cannot determine truthiness of string #{obj.to_s}")
    end
  end

  def send_metric payload
    socket = TCPSocket.new(GRAPHITE_SERVER, GRAPHITE_PORT)
    socket.puts payload
    socket.close
  end

  def process
    Puppet.debug "Sending status for #{self.host} to Graphite server at #{GRAPHITE_SERVER}"
    
    if convert_to_bool(GRAPHITE_USE_FQDN_TREE)
      prefix = self.host.split(".").reverse.join(".")
      prefix = [GRAPHITE_PREFIX, prefix].join(".") if GRAPHITE_PREFIX
    else
      prefix = self.host.gsub(".","_")
      prefix = [GRAPHITE_PREFIX, prefix].join(".") if GRAPHITE_PREFIX
    end

    if convert_to_bool(GRAPHITE_APPEND_PUPPET_TO_PREFIX)
      prefix = "#{prefix}.puppet"
    end

    epochtime = Time.now.utc.to_i

    self.metrics.each { |metric,data|
      data.values.each { |val| 
        name = "#{prefix}.metrics.#{metric}.#{val[1]}"
        value = val[2]

        send_metric "#{name} #{value} #{epochtime}"
      }
    }
  end
end
