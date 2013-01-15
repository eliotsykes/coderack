# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'

begin
  require 'jslint/tasks'
  JSLint.config_path = "config/jslint.yml"
rescue LoadError
  # ignore
end

Coderack::Application.load_tasks
