# CAS 3.5 
class LoginTicket < ActiveRecord::Base
  # begins with "LT-"
  include Consumable
  set_table_name "casfuji_lt"
  
  def valid?
    @name == "LT-test_service_ticket"
  end

  def self.generate
    LoginTicket.new :name => ("LT-".concat ::UUID.new.generate)
  end

end
