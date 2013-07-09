source 'http://rubygems.org'

gem 'rails', '~> 3.2.13'
gem 'mysql2'
gem 'sqlite3'

gem "warden"
gem "warden-openid", "0.1.0"
gem "rack-openid"

gem "rack-noie", :require => "noie"
gem "rdiscount"
gem "RedCloth"
gem "twitter"
gem "oauth", "0.4.2"
gem "webrat", "0.7"
gem 'faker'
gem 'bitly'
gem 'kaminari'

group :staging do
  gem "rack-revision-info", ">= 0.3.7"
  gem "nokogiri"  # for rack-revision-info
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "mocha", :require => false
  gem 'jslint_on_rails'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem "mongrel", "1.2.0.pre2"
end
