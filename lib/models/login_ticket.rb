# CAS 3.5 
class LoginTicket < ActiveRecord::Base
  # begins with "LT-"
  include Consumable
  set_table_name "casfuji_lt"
  
  def self.valid?(login_ticket_name)
    LoginTicket.find_by_name(login_ticket_name)
  end

  def self.consume(login_ticket_name)
    login_ticket = LoginTicket.valid?(login_ticket_name)
    login_ticket.consume! if not login_ticket.nil?
  end
  
  def self.generate(client_hostname)
    LoginTicket.create(:name => ("LT-".concat ::UUID.new.generate),
      :client_hostname => client_hostname)
  end
end
