# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.3'
gem 'coffee-rails', '~> 4.2'
gem 'jbuilder', '~> 2.5'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.4'
gem 'redis', '~> 4.1.3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# gem 'activerecord-import' This is important when we import records in associations
gem 'devise', '~> 4.4.0'
gem 'figaro', '~> 1.1.1'
gem 'haml-rails', '~> 2.0.1'
gem 'sidekiq', '~> 6.0.3'
gem 'spree', '~> 3.4.0'
gem 'spree_auth_devise', '~> 3.4'
gem 'spree_gateway', '~> 3.3'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'annotate', '~> 3.0.3'
  gem 'bullet', '~> 6.0.2'
  gem 'letter_opener', '~> 1.7.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop', '~> 0.77.0', require: false
  gem 'rubycritic', '~> 4.2.2', require: false
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '~> 3.29.0'
  # gem 'capybara-email', '~> 3.0.1' can be used for more email content testing
  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot_rails', '~> 5.1.1'
  gem 'rspec-rails', '~> 3.9.0'
  gem 'selenium-webdriver', '~> 3.142.6'
  gem 'shoulda-matchers', '~> 4.1.2'
  gem 'webdrivers', '~> 4.1.3'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
