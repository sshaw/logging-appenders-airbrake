require "rails"
require "logging/appenders/airbrake"


module Logging
  module Appenders
    class Airbrake
      class Railtie < ::Rails::Railtie
        initializer "logging.appenders.airbrake" do
          # Rails >= 3.2 uses ActionDispatch::DebugExceptions
          file = defined?(ActionDispatch::DebugExceptions) ? "debug_exceptions" : "show_exceptions"
          Logging::Appenders.Airbrake.backtrace_filters << %r{/lib/action_dispatch/middleware/#{ file }.rb}
        end
      end
    end
  end
end
