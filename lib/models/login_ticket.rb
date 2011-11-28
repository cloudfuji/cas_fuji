# CAS 3.5 
class LoginTicket
  # begins with "LT-"
  attr_accessor :name
  
  def valid?
    @name == "LT-test_service_ticket"
  end

  def self.find_by_name(name)
    return nil unless name

    login_ticket = self.new
    login_ticket.name = name
    login_ticket
  end
end
