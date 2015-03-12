require "airbrake"
require "logging/appender"

module Logging::Appenders
  def self.airbrake(*args)
    if args.empty?
      return self["airbrake"] || Logging::Appenders::Airbrake.new
    end

    Logging::Appenders::Airbrake.new(*args)
  end

  class Airbrake < Logging::Appender
    VERSION = "0.0.2"

    # Ignore errors logged by an Airbrake sender
    INTERNAL_BT_FILTER = %r{:in\s+`send_to_airbrake'}

    # Remove calls to this class in the stacktrace sent to Airbrake
    AIRBRAKE_BT_FILTER = lambda do |line|
      line =~ %r{/logging-[^/]+/lib/logging/} ? nil : line
    end

    def initialize(*args)
      args.compact!

      name = args.first.is_a?(String) ? args.shift : "airbrake"
      args = args.first.is_a?(Hash)   ? args.shift : {}

      super(name, args.merge(:level => :error))

      cfg = ::Airbrake.configuration
      cfg.framework = "Logging #{Logging.version}"

      @options = args.shift || {}
      @options[:backtrace_filters] ||= []
      @options[:backtrace_filters] << AIRBRAKE_BT_FILTER

      @options.each do |k,v|
        unless ::Airbrake::Configuration::OPTIONS.include?(k)
          raise ArgumentError, "unknown Airbrake configuration option #{k}"
        end

        # Airbrake array attributes have no setter
        if cfg[k].is_a?(Array)
          cfg[k].concat(Array(v))
        else
          cfg.public_send("#{k}=", v)
        end
      end
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
