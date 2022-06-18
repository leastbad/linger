require "redis"

module Linger::Connections
  mattr_accessor :connections, default: {}
  mattr_accessor :configurator
  mattr_accessor :connector, default: ->(config) { Redis.new(config) }

  def configured_for(name)
    connections[name] ||= Linger.instrument :meta, message: "Connected to #{name}" do
      connector.call configurator.config_for("redis/#{name}")
    end
  end

  def clear_all
    Linger.instrument :meta, message: "Connections all cleared" do
      connections.each_value do |connection|
        if Linger.namespace
          keys = connection.keys("#{Linger.namespace}:*")
          connection.del keys if keys.any?
        else
          connection.flushdb
        end
      end
    end
  end
end
