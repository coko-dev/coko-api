source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

# Core
gem 'bootsnap', '>= 1.4.2', require: false
gem 'puma', '~> 4.1'
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'

# DB
gem 'mysql2'
gem 'ridgepole'

# HTTP Client
gem 'typhoeus'

group :development, :test do
  ### Server
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  ### Debugging
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug'
  gem 'pry-doc'
  gem 'pry-rails'

  ### Inspection
  gem 'brakeman'

  ### Testing
  gem 'rails-controller-testing'
  gem 'rspec'
  gem 'rspec-rails', github: 'rspec/rspec-rails', tag: 'v4.0.0.beta3' # NOTE: Temporary for Rails 6

  ### Linter
  gem 'reek'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  ### Core
  gem 'listen', '~> 3.2'

  ### Error
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
end
