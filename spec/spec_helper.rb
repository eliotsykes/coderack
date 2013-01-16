ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)

require 'rspec/rails'
require 'rspec/rails/mocha'
require 'support/coderack_matchers'
require 'support/coderack_model_helper'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include Coderack::Test::Matchers
  config.include Warden::Test::Helpers
end
