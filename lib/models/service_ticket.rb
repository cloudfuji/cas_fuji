# CAS 3.1 ServiceTicket names begin with "ST-" Services (apps that use
# CAS) MUST be able to accept ServiceTickets up to 32 characters, but
# it's RECOMMENDED they accept up to 256 characters
class ServiceTicket < ActiveRecord::Base
  set_table_name "casfuji_st"

  # Mixin module behaviors
  include Consumable
  include Ticket

  def consumed?
    not self.consumed.nil?
  end

  def service_valid?(service)
    self.service == CGI.escape(service)
  end

  def self.generate(service, permanent_id, client_hostname)
    ServiceTicket.create(:name            => self.unique_ticket_name('ST'),
                         :permanent_id    => permanent_id,
                         :service         => service,
                         :client_hostname => client_hostname)
  end
end
