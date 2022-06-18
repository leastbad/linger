require "active_support/log_subscriber"

class Linger::LogSubscriber < ActiveSupport::LogSubscriber
  def meta(event)
    info formatted_in(MAGENTA, event)
  end

  private

  def formatted_in(color, event, type: nil)
    color "  Linger #{type} (#{event.duration.round(1)}ms)  #{event.payload[:message]}", color, true
  end
end

Linger::LogSubscriber.attach_to :linger
