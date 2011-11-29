$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib/')

ENV['RACK_ENV'] ||= "test"

require 'rspec'
require 'rack/test'
require 'sinatra'
require 'cover_me'
require 'capybara/rspec'
require 'webmock/rspec'
require 'cgi'

require 'database_cleaner'

set :environment, :test

require 'cas_fuji'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{Dir.pwd}/spec/support/**/*.rb"].each { |file| require file }

Capybara.javascript_driver = :webkit
Capybara.app = CasFuji::App

RSpec.configure do |config|
  config.mock_with :rspec
  
  config.include Capybara::DSL
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
