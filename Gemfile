source 'http://rubygems.org'

# Core gems
gem 'sinatra'
gem 'json', '>=1.4.6'
gem 'nokogiri'

# Database gems
gem 'pg', '>=0.10.0'
gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'activerecord'
gem 'sinatra-activerecord'

# Default random generator
gem 'crypt-isaac'

# Misc. gems
gem 'uuid'
gem 'awesome_print'
gem 'addressable'


# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'foreman'
  gem 'ruby-debug19'
  gem 'shoulda-matchers'
  gem 'ZenTest', '>=4.4.2'
  gem 'vcr'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'email_spec'
  gem 'jasmine'
  gem 'ci_reporter'
  gem 'watchr'
  gem 'shotgun'
end

group :test do
  gem 'database_cleaner'
  gem 'cover_me', '>= 1.0.0.rc6'
  gem 'capybara-webkit'
  gem 'rspec'
  gem 'rspec-prof'
  gem 'rack-test'
  gem 'webmock'
end
