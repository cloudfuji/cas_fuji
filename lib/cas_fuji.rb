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

# Load the base authenticator
require 'cas_fuji/authenticators/base'

# Load the authenticators specified in the config file
CasFuji.config[:authenticators].each do |authenticator|
  authenticator["source"] = authenticator["class"].underscore if authenticator["source"].nil?
  require authenticator["source"]
end

require 'consumable'
require 'ticket'

# Require all of the models
# Dir["#{Dir.pwd}/lib/cas_fuji/models/**/*.rb"].reverse.each { |file| puts file; require file }

require "cas_fuji/models/login_ticket"
require "cas_fuji/models/service_ticket"


# Load sinatra app
require 'cas_fuji/app'
