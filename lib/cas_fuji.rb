$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '.')

require 'sinatra'
require 'builder'
require 'uuid'
require 'cgi'
require 'ap'

require 'active_support/core_ext/string'
require 'active_support/memoizable'
require 'active_record'
require 'addressable/uri'

require 'cas_fuji/exception'

# Load app config
require 'cas_fuji/config'

# Load the base authenticator
require 'cas_fuji/authenticators/base'

# Load the authenticators specified in the config file
CasFuji.config[:authenticators].each do |authenticator|
  authenticator[:source] = authenticator[:class].underscore if authenticator[:source].nil?
  require authenticator[:source]
end

# ::ActiveRecord::Base.establish_connection(CasFuji.config[:database])

require 'consumable'

# Load the models
require "cas_fuji/models/base_ticket"
require "cas_fuji/models/login_ticket"
require "cas_fuji/models/service_ticket"
require "cas_fuji/models/proxy_ticket"
require "cas_fuji/models/proxy_granting_ticket"
require "cas_fuji/models/ticket_granting_ticket"

# Load sinatra app
require 'cas_fuji/app'
