require "active_support"

require "linger/version"

require "linger/connections"
require "linger/log_subscriber"
require "linger/namespace"
require "linger/authentication"

require "linger/railtie" if defined?(Rails::Railtie)

module Linger
  include Authentication
  include Namespace
  include Connections
  extend self

  mattr_accessor :logger

  def redis(config: :shared)
    configured_for(config)
  end

  def allow(*identifiers, **options)
    key = build_key(identifiers)
    instrument :meta, message: "Allowing #{key}" do
      redis.set key, options[:data] || Time.zone.now
    end
  end

  def deny(*identifiers)
    key = build_key(identifiers)
    instrument :meta, message: "Denying #{key}" do
      redis.del key
    end
  end

  def instrument(channel, **options, &block)
    ActiveSupport::Notifications.instrument("#{channel}.linger", **options, &block)
  end

  private

  def build_key(identifiers)
    Linger.namespaced_key(identifiers.map do |identifier|
      case identifier
      when ActionDispatch::Request::Session
        identifier.id.to_s
      when Rack::Session::SessionId
        identifier.to_s
      else
        identifier.respond_to?(:to_gid_param) ? identifier.to_gid_param : identifier.to_s
      end
    end.sort.join(":"))
  end
end
