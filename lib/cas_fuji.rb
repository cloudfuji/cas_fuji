require 'sinatra'
require 'builder'
require 'uuid'
require 'cgi'
require 'ap'
require 'sinatra/activerecord'

# Load app config
require './lib/cas_fuji/config'

# Load sinatra app
require './lib/cas_fuji/app'

require 'consumable'

# Require all of the models
Dir["#{Dir.pwd}/lib/models/**/*.rb"].reverse.each { |file| require file }
