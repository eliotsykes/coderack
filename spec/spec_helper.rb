require 'simplecov'
SimpleCov.start

ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)


require 'rspec/rails'
require 'mocha/setup'
require 'support/coderack_matchers'
require 'support/coderack_model_helper'

RSpec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.include Coderack::Test::Matchers
  config.include Warden::Test::Helpers
end
