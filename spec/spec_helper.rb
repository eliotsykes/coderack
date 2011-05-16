ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(Rails)
require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Rspec.configure do |config|
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.include Coderack::Test::Matchers
  config.include Warden::Test::Helpers
end
