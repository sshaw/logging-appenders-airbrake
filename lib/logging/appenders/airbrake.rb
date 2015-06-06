require "airbrake"
require "logging"

module Logging::Appenders
  def self.airbrake(*args)
    if args.empty?
      return self["airbrake"] || Logging::Appenders::Airbrake.new
    end

    Logging::Appenders::Airbrake.new(*args)
  end

  class Airbrake < Logging::Appender
    VERSION = "0.0.3"

    # Ignore errors logged by an Airbrake sender
    INTERNAL_BT_FILTER = %r{:in\s+`send_to_airbrake'}.freeze

    # Remove calls to this class in the stacktrace sent to Airbrake
    AIRBRAKE_BT_FILTER = lambda do |line|
      line =~ %r{/logging-[^/]+/lib/logging/} ? nil : line
    end

    def initialize(*args)
      cfg = ::Airbrake.configuration
      cfg.framework = "Logging #{Logging.version}"

      appender = { :level => :error }

      args.compact!
      name = args.first.is_a?(String) ? args.shift : "airbrake"
      airbrake = args.last.is_a?(Hash) ? args.pop : {}

      airbrake[:backtrace_filters] ||= []
      airbrake[:backtrace_filters] << AIRBRAKE_BT_FILTER

      airbrake.keys.each do |name|
        unless ::Airbrake::Configuration::OPTIONS.include?(name)
          appender[name] = airbrake.delete(name)
          next
        end

        # Airbrake array attributes have no setter
        if cfg[name].is_a?(Array)
          cfg[name].concat(Array(airbrake[name]))
        else
          cfg.public_send("#{name}=", airbrake[name])
        end
      end

      super(name, appender)
    end

    private

    def write(event)
      return self if caller.any? { |bt| bt =~ INTERNAL_BT_FILTER }

      # Docs say event can be a String too, not sure when/how but we'll check anyways
      error = event.is_a?(Logging::LogEvent) ? event.data : event
      error = { :error_message => error } if error.is_a?(String)

      ::Airbrake.notify_or_ignore(error)
      self
    end
  end
end

require "logging/appenders/airbrake/railtie" if defined?(Rails::Railtie)
