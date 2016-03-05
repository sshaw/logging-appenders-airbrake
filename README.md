# Logging::Appenders::Airbrake

[![Build Status](https://travis-ci.org/sshaw/logging-appenders-airbrake.svg?branch=master)](https://travis-ci.org/sshaw/logging-appenders-airbrake)

Airbrake appender for [the Logging gem](https://github.com/TwP/logging). **Airbrake v5 is not supported.**

## Overview

    require "logging"
    require "logging/appenders/airbrake"

	log = Logging.logger[self]
	log.add_appenders(
	  Logging.appenders.airbrake(:api_key => "123XYZ", :ignore => %w[SomeThang AnotherThang])
    )

    # Or

    Airbrake.configure do |cfg|
      # ...
    end

	log.add_appenders(Logging.appenders.airbrake)

	log.info  "Not sent to airbrake"
	log.error "Airbrake here I come!"
	log.error SomeError.new("See you @ airbrake.io!")

## Description

Only events with the `:error` log level are sent to Airbrake. Errors are not sent asynchronously,
though this can be changed via `Airbrake.configure`.

By default the appender  will be named `"airbrake"`. This can be changed by passing a name
to the `airbrake` method:

    Logging.appenders.airbrake("another_name", options)

Airbrake configuration can be done via `Airbrake.configure` or via `Logging.appenders.airbrake`.
All [`Airbrake::Configuration` options](http://www.rubydoc.info/gems/airbrake/4.3.0/Airbrake/Configuration) can be passed
to the latter.

Internally `Airbrake.configure` will be called *only if* `Airbrake.sender` has not been set. This gives
[some options set by `Airbrake.configure`](http://www.rubydoc.info/gems/airbrake/4.3.0/Airbrake/Sender) precedence over those
passed into the logger.

## Using With `logging-rails`

If you're already using Airbrake then your current Airbrake initializer will be used.
If not you can either create one or specify your options in `config/logging.rb`.

In `config/logging.rb`:

	Logging.appenders.airbrake if config.log_to.include?("airbrake")

In `config/environments/xxx.rb`, where `xxx` corresponds to the desired `Rails.env`:

	config.log_to = %w[airbrake]  # or %w[airbrake file email] # etc...

## Author

Skye Shaw [sshaw AT gmail.com]

## License

Released under the MIT License: www.opensource.org/licenses/MIT
