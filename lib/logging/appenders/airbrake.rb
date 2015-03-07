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
    # Ignore errors logged by an Airbrake sender
    INTERNAL_BT_FILTER = %r{:in\s+`send_to_airbrake'}

    # Remove calls to this class in the stacktrace sent to Airbrake
    AIRBRAKE_BT_FILTER = lambda do |line|
      line =~ %r{/logging-[^/]+/lib/logging/} ? nil : line
    end

    attr :options

    def self.backtrace_filters
      @backtrace_filters ||= [INTERNAL_BT_FILTER]
    end

    def initialize(*args)
      args.compact!

      name = args.first.is_a?(String) ? args.shift : "airbrake"
      super(name, :level => :error)

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

    def ignore_caller?(bt)
      bt.any? do |line|
        self.class.backtrace_filters.any? { |filter| line =~ filter }
      end
    end

    def write(event)
      return self if ignore_caller?(caller)

      if ::Airbrake.configuration.configured?
        # Docs say event can be a String too, not sure when/how but we'll check anyways
        error = event.is_a?(Logging::LogEvent) ? event.data : event
        error = { :error_message => error } if error.is_a?(String)

        ::Airbrake.notify_or_ignore(error)
      else
        # TODO: better to just set Airbrake's logger to something so it can log this?
        Logging.log_internal { 'Not logging #{event.inspect}: Airbrake is not configured' }
      end
      self
    end
  end
end
