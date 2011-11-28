require 'rspec'
require 'rack/test'
require 'sinatra'
require 'cover_me'
require 'capybara/rspec'
require 'webmock/rspec'
require 'cgi'

set :environment, :test

require File.join(File.dirname(__FILE__), '..', 'lib', 'cas_fuji.rb')

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{Dir.pwd}/spec/support/**/*.rb"].each { |file| require file }

Capybara.javascript_driver = :webkit

RSpec.configure do |config|
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true
end
