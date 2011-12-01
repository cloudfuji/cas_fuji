# CAS 3.1
module CasFuji
  module Models
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

      def service_url
        CGI.unescape(self.service)
      end

      def service_valid?(service)
        CGI.unescape(self.service) == service
      end

      def self.generate(service, permanent_id, client_hostname)
        CasFuji::Models::ServiceTicket.create(
          :name            => ("ST-".concat ::UUID.new.generate),
          :permanent_id    => permanent_id,
          :service         => service,
          :client_hostname => client_hostname)
      end
    end
  end
end
