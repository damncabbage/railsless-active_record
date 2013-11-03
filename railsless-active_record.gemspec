# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'railsless/active_record/version'

Gem::Specification.new do |spec|
  spec.name          = "railsless-active_record"
  spec.version       = Railsless::ActiveRecord::VERSION
  spec.authors       = ["Rob Howard"]
  spec.email         = ["rob@robhoward.id.au"]
  spec.description   = %q{Provides a ActiveRecord Rake tasks and integration for Sinatra, Goliath, etc.}
  spec.summary       = %q{Provides a ActiveRecord Rake tasks and integration for Sinatra, Goliath and other apps that aren't using Rails.}
  spec.homepage      = "https://github.com/damncabbage/railsless-active_record"
  spec.license       = "Apache License, Version 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "simplecov", "~> 0.7"
  spec.add_dependency "rake"
  spec.add_dependency "activerecord", "~> 4.0" # < 4 is a pain in the butt to add Rake tasks for.
end
