# CAS 3.1
class ServiceTicket < ActiveRecord::Base
  # begins with "ST-"
  # Services MUST be able to accept ServiceTickets
  # up to 32 characters, but it's RECOMMENDED they
  # accept up to 256 characters
  include Consumable
  set_table_name "casfuji_st"

  def self.valid?(service, username, ticket_name)
    ServiceTicket.find(:all,
      :conditions => {
        :name     => ticket_name,
        :username => username,
        :service  => service,
        :consumed => false})
  end

  def self.generate(service, username)
    st = ServiceTicket.create(
      :name => ("ST-".concat ::UUID.new.generate),
      :username => username,
      :service  => service)
  end

  def service_valid?(service)
    puts "#{service} == #{'http://target-service.com/service_url'}"
    service == "http://target-service.com/service_url"
  end

end
