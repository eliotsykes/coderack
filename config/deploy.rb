require 'capistrano/ext/multistage'
require 'bundler/capistrano'

set :application, "coderack"
set :repository, "git://github.com/LunarLogicPolska/coderack.git"
set :scm, :git
set :keep_releases, 10
set :use_sudo, false


after 'deploy', 'deploy:cleanup'
after 'deploy:migrations', 'deploy:cleanup'
after "deploy:update_code", "deploy:copy_configuration"

namespace :deploy do

  desc "Copies configuration files (e.g. database.yml) from shared to current"
  task :copy_configuration do
    %w(application.yml database.yml).each do |filename|
      run "cp #{shared_path}/config/#{filename} #{release_path}/config/#{filename}"
    end
  end

end
