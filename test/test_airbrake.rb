# -*- coding: utf-8 -*-
require "minitest/autorun"
require "minitest/mock"

require "logging"
require "logging/appenders/airbrake"

class TestAirbrake < MiniTest::Unit::TestCase
  def test_configuration_without_appender_name
    app = appender(config)

    refute_nil Logging.logger["airbrake"]
    assert_same app, Logging.appenders.airbrake

    assert_equal config[:api_key], Airbrake.configuration.api_key
    assert_equal config[:host], Airbrake.configuration.host
    config[:ignore].each do |name|
      assert_includes Airbrake.configuration.ignore, name
    end
  end

  def test_configuration_with_appender_name
    app = appender("sshaw", config)

    refute_nil Logging.logger["sshaw"]
    refute_same app, Logging.appenders.airbrake

    assert_equal config[:api_key], Airbrake.configuration.api_key
    assert_equal config[:host], Airbrake.configuration.host
    config[:ignore].each do |name|
      assert_includes Airbrake.configuration.ignore, name
    end
  end

  def test_invalid_configuration
    assert_raises(ArgumentError, /unknown/) { appender(:ass => "bass") }
  end

  def test_only_error_level_logged
    count = 0
    app = appender
    app.define_singleton_method(:write) { |e| count += 1 }

    log = Logging.logger[self]
    log.add_appenders(app)

    log.info("Hi")
    log.error("Hello hello!")
    log.error("¡Hola!")
    log.debug("Oizinho")
    log.warn("Perigo")

    assert_equal 2, count
  end

  private
  def config
    @config ||= {
      :api_key => "X123",
      :host    => "example.com",
      :ignore  => %w[A B]
    }
  end

  def appender(*args)
    args << { :api_key => "X123" } unless args.last.is_a?(Hash)
    Logging.appenders.airbrake(*args)
  end
end
