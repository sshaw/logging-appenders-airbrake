require "rails"
require "logging/appenders/airbrake"

module Logging
  module Appenders
    class Airbrake
      class Railtie < ::Rails::Railtie
        config.after_initialize do |app|
          next unless app.middleware.include?(::Airbrake::Rails::Middleware)

          log = app.env_config["action_dispatch.logger"]
          next unless log.is_a?(Logging::Logger)

          # After sending an exception to Airbrake its middleware passes the exception (`raise`es) it up
          # the stack. Rails' middleware (DebugException,ShowExceptions) ends up logging these as fatal,
          # which triggers the Airbrake appender. To avoid sending the exception twice we remove the appender.
          log.appenders = Logging.logger.root.appenders if log.appenders.none?
          log.appenders = log.appenders.reject { |a| a.is_a?(Logging::Appenders::Airbrake) }
          log.additive = false

          app.env_config["action_dispatch.logger"] = log
        end
      end
    end
  end
end
