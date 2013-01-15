source 'http://rubygems.org'

gem 'rails', '3.0.19'
gem 'mysql2', '~> 0.2.3'
gem "mongrel", "1.2.0.pre2"

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
  gem "mocha"
  gem 'jslint_on_rails'
  if RUBY_VERSION.include?('1.9')
    gem 'ruby-debug19'
  else
    gem 'ruby-debug'
  end
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end
