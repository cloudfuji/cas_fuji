$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '.')

require 'sinatra'
require 'builder'
require 'uuid'
require 'cgi'
require 'ap'
require 'sinatra/activerecord'

require 'cas_fuji/exception'

# Load app config
require 'cas_fuji/config'

# Load sinatra app
require 'cas_fuji/app'

require 'consumable'

# Require all of the models
Dir["#{Dir.pwd}/lib/models/**/*.rb"].reverse.each { |file| require file }
