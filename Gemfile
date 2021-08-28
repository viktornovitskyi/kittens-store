ruby '2.6.6'

source 'https://rubygems.org'

gem 'sinatra'
gem 'rack'
gem 'rake'

gem 'pg', '~> 0.18'
gem 'activerecord'
gem 'sinatra-activerecord'

group :development do
  gem 'rubocop', '0.89'
  gem 'rubocop-junit-formatter', require: false
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'ffaker'
end
