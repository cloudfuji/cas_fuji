$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '.')

require 'sinatra'
require 'builder'
#require 'uuid'
require 'cgi'
#require 'ap'

require 'active_support/core_ext/string'
require 'active_support/memoizable'
require 'active_record'
require 'addressable/uri'

require_relative 'exception'

# Load app config
require_relative 'config'

# Load the base authenticator
require_relative 'authenticators/base'

# Load the authenticators specified in the config file
CasFuji.config[:authenticators].each do |authenticator|
  authenticator[:source] = authenticator[:class].underscore if authenticator[:source].nil?
  require authenticator[:source]
end

require CasFuji.config[:authorizer][:source]

# Load the models
require_relative "models/base_ticket"
require_relative "models/login_ticket"
require_relative "models/service_ticket"
require_relative "models/proxy_ticket"
require_relative "models/proxy_granting_ticket"
require_relative "models/ticket_granting_ticket"

# Load resque worker
require_relative 'workers/logout_notifier'

# Load sinatra app
require_relative 'app'


