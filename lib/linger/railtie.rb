class Linger::Railtie < ::Rails::Railtie
  config.linger = ActiveSupport::OrderedOptions.new

  initializer "linger.testing" do
    ActiveSupport.on_load(:active_support_test_case) do
      parallelize_setup { |worker| Linger.namespace = "test-#{worker}" }
      teardown { Linger.clear_all }
    end
  end

  initializer "linger.logger" do
    Linger::LogSubscriber.logger = config.linger.logger || Rails.logger
  end

  initializer "linger.configuration" do
    Linger::Connections.connector = config.linger.connector || ->(config) { Redis.new(config) }
  end

  initializer "linger.configurator" do
    Linger.configurator = Rails.application
  end

  initializer "linger.action_cable" do
    ActiveSupport.on_load(:action_cable) do
      StimulusReflex::Reflex.include Linger::Authentication
    end
  end

  rake_tasks do
    path = File.expand_path("..", __dir__)
    Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
  end
end
