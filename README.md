# Logging::Appenders::Airbrake

Airbrake appender for [the logging gem](https://github.com/TwP/logging).

## Overview

    require "logging"
    require "logging/appenders/airbrake"

	log = Logging.logger[self]
	log.appenders = Logging.appenders.airbrake(:api_key => "123XYZ", :ignore => %w[SomeThang AnotherThang])

    # Or

    Airbrake.configure do |cfg|
      # ...
    end

	log.appenders = Logging.appenders.airbrake
	
	log.info  "Not sent to airbrake"
	log.error "Airbrake here I come!"
	log.error SomeError.new("See you @ airbrake.io!")	

## Description

Only events with the `:error` log level are sent to Airbrake. By default the appender 
will be named `"airbrake"`. This can be changed by passing a name to the `airbrake` method:

    Logging.appenders.airbrake("another_name", options)

Airbrake configuration can be done via `Airbrake.configure` or via `Logging.appenders.airbrake`. 
All Airbrake options can be passed to the latter.

## Author

Skye Shaw [sshaw AT gmail.com]

## License

Released under the MIT License: www.opensource.org/licenses/MIT
