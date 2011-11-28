require 'sinatra'
require 'builder'
require 'cgi'
require 'ap'
require 'sinatra/activerecord'
# Load app config
require './lib/cas_fuji/config'

# Load sinatra app
require './lib/cas_fuji/app'

# Require all of the models
Dir["#{Dir.pwd}/lib/models/**/*.rb"].each { |file| require file }

