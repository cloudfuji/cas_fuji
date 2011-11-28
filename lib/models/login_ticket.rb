# CAS 3.5 
class LoginTicket < ActiveRecord::Base
  # begins with "LT-"
  set_table_name "casfuji_lt"
  attr_accessor :name
  
  def valid?
    @name == "LT-test_service_ticket"
  end

  def initialize
    super
    name = UUID.new.generate
    self
  end

  def self.find_by_name(name)
    return nil unless name

    login_ticket = self.new
    login_ticket.name = name
    login_ticket
  end
end
