# CAS 3.1
class ServiceTicket
  # begins with "ST-"
  # Services MUST be able to accept ServiceTickets
  # up to 32 characters, but it's RECOMMENDED they
  # accept up to 256 characters
  set_table_name "casfuji_st"

  attr_accessor :name
  
  def valid?
    @name == "ST-test_service_ticket"
  end

  def username
    "valid_username"
  end

  def service_valid?(service)
    puts "#{service} == #{'http://target-service.com/service_url'}"
    service == "http://target-service.com/service_url"
  end

  def self.find_by_name(name)
    return nil unless name

    ticket = self.new
    ticket.name = name
    ticket
  end
end
