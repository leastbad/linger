require "test_helper"
require "active_support/log_subscriber/test_helper"

class LogSubscriberTest < ActiveSupport::TestCase
  include ActiveSupport::LogSubscriber::TestHelper

  teardown { ActiveSupport::LogSubscriber.log_subscribers.clear }

  test "proxy" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :linger, Linger::LogSubscriber.new

    instrument "proxy.linger", message: "foo"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33m  Linger Proxy \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "migration" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :linger, Linger::LogSubscriber.new

    instrument "migration.linger", message: "foo"

    assert_equal 1, @logger.logged(:debug).size
    assert_match(
      /\e\[1m\e\[33m  Linger Migration \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:debug).last
    )
  end

  test "meta" do
    ActiveSupport::LogSubscriber.colorize_logging = true
    ActiveSupport::LogSubscriber.attach_to :linger, Linger::LogSubscriber.new

    instrument "meta.linger", message: "foo"

    assert_equal 1, @logger.logged(:info).size
    assert_match(
      /\e\[1m\e\[35m  Linger  \(\d+\.\d+ms\)  foo\e\[0m/,
      @logger.logged(:info).last
    )
  end

  private

  def instrument(...)
    ActiveSupport::Notifications.instrument(...)
    wait
  end
end
