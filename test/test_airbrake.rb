require "minitest/autorun"
require "minitest/mock"

require "logging"
require "logging/appenders/airbrake"

class TestAirbrake < MiniTest::Unit::TestCase
  def setup
    @log = Logging.logger[self]
  end

  def test_configuration
    config = {
      :api_key => "X123",
      :host    => "example.com",
      :ignore  => %w[A B]
    }

    @log.add_appenders(appender(config))

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

    @log.add_appenders(app)
    @log.info("Hi")
    @log.error("Hello hello!")
    @log.debug("Oizinho")

    assert_equal 1, count
  end

  private
  def appender(config = { :api_key => "X123" })
    Logging.appenders.airbrake(config)
  end
end
