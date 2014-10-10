# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "logging-appenders-airbrake"
  spec.version       = "0.0.1"
  spec.authors       = ["Skye Shaw"]
  spec.email         = ["skye.shaw@gmail.com"]
  spec.summary       = %q{Airbrake appender for the logging gem}
  spec.description   = %q{An appender for the logging gem that will send all messages logged at the :error level to Airbrake}
  spec.homepage      = "https://github.com/sshaw/logging-appenders-airbrake"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = "> 1.8.7"

  spec.add_dependency "airbrake"
  spec.add_dependency "logging"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
