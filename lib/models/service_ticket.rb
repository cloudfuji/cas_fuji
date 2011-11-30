# CAS 3.1
class ServiceTicket < ActiveRecord::Base
  # begins with "ST-"
  # Services MUST be able to accept ServiceTickets
  # up to 32 characters, but it's RECOMMENDED they
  # accept up to 256 characters
  include Consumable
  set_table_name "casfuji_st"

  def consumed?
    not self.consumed.nil?
  end

  def not_consumed?
    !self.consumed?
  end

  def service_valid?(service)
    self.service == CGI.escape(service)
  end

  def self.generate(service, permanent_id, client_hostname)
    ServiceTicket.create(
      :name            => ("ST-".concat ::UUID.new.generate),
      :permanent_id    => permanent_id,
      :service         => service,
      :client_hostname => client_hostname)
  end
end
