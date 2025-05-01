source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails"

gem "importmap-rails"
gem "lamby"
gem "mysql2", "~> 0.5"
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "jbuilder"
gem "rack"
gem 'ridgepole'
gem 'slim-rails'
gem 'html2slim-ruby3'
gem 'bootstrap', '~> 5.3.0'
gem 'sassc-rails'
gem 'simple_form'

group :development, :test do
  gem "debug"
  gem "webrick"
end

group :development do
  gem "web-console"
	gem 'rubocop-rails-omakase', require: false
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

group :production do
  gem 'lograge'
end
