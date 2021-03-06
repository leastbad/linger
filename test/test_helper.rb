require "bundler/setup"
require "active_support/test_case"
require "active_support/testing/autorun"
require "minitest/mock"
require "byebug"

require "linger"

Linger.configurator = Class.new {
  def config_for(name)
    {db: "1"}
  end
}.new

ActiveSupport::LogSubscriber.logger = ActiveSupport::Logger.new($stdout) if ENV["VERBOSE"]

class ActiveSupport::TestCase
  teardown { Linger.clear_all }

  class RedisUnavailableProxy
    def multi
      yield
    end

    def pipelined
      yield
    end

    def method_missing(*)
      raise Redis::BaseError
    end

    def respond_to_missing?(*)
      super
    end
  end

  def stub_redis_down(redis_holder, &block)
    redis_holder.try(:proxy) || redis_holder \
      .stub(:redis, RedisUnavailableProxy.new, &block)
  end
end
