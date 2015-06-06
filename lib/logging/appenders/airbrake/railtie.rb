require "rails"
require "logging/appenders/airbrake"

module Logging
  module Appenders
    class Airbrake
      class Railtie < ::Rails::Railtie
        config.after_initialize do |app|
          next unless defined?(::Airbrake::Rails::Middleware) && app.middleware.include?(::Airbrake::Rails::Middleware)

          # Don't use is_a?, the logger maybe be wrapped in ActiveSupport::TaggedLogging
          log = app.env_config["action_dispatch.logger"]
          next unless log.respond_to?(:appenders=) && log.respond_to?(:additive=)

          # After sending an exception to Airbrake its middleware passes the exception (`raise`es) it up
          # the stack. Rails' middleware (DebugException, ShowExceptions) ends up logging these as fatal,
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
