source 'http://rubygems.org'

gem 'rails', '3.2.13'

ruby '2.0.0'

gem "warden"
gem "warden-openid"
gem "rack-openid"

gem "rack-noie", :require => "noie"
gem "rdiscount"
gem "RedCloth"
gem "twitter"
gem "oauth"
gem "webrat"
gem 'bitly'
gem 'kaminari'
gem 'figaro'

group :staging do
  gem "rack-revision-info"
  gem "nokogiri"  # for rack-revision-info
end

group :development, :test do
  gem 'sqlite3'
  gem 'mysql2'

  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem 'jslint_on_rails'
end

gem 'simplecov', :require => false, :group => :test

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem "mongrel", "1.2.0.pre2"
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
end
