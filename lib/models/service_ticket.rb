# CAS 3.1
module CasFuji
  module Models
    class ServiceTicket < CasFuji::Models::BaseTicket
      # begins with "ST-"
      # Services MUST be able to accept ServiceTickets
      # up to 32 characters, but it's RECOMMENDED they
      # accept up to 256 characters
      set_table_name "casfuji_st"

      def self.generate(authenticator, service, permanent_id, client_hostname)
        CasFuji::Models::ServiceTicket.create(
          :authenticator   => authenticator,
          :name            => unique_ticket_name("ST"),
          :permanent_id    => permanent_id,
          :service         => service,
          :client_hostname => client_hostname)
      end

      def self.validate_ticket(service_url, ticket_name)
        return [:INVALID_REQUEST, "Ticket is required"] if ticket_name.nil?
        return [:INVALID_REQUEST, "Service is required"] if service_url.nil?

        ticket = self.find_by_name(ticket_name)

        return [:INVALID_TICKET, "Invalid ticket"] if ticket.nil? or not ticket.ticket_valid?
        return [:INVALID_SERVICE, "Service does not match ticket"] if not ticket.service_valid?(service_url)

        return [nil, "Ticket and service are valid", ticket]
      end


      def notify_logout
        puts "LOGOUT SERVICE: #{self.service}"
        uri = URI.parse(self.service)
        puts "PARSED SERVICE: #{uri.inspect}"
        uri.path = '/' if uri.path.empty?
        time = Time.now

        logout_template = URI.escape(%{<samlp:LogoutRequest ID="#{self.id}" Version="2.0" IssueInstant="#{time.rfc2822}">
            <saml:NameID></saml:NameID>
            <samlp:SessionIndex>#{self.name}</samlp:SessionIndex>
            </samlp:LogoutRequest>})

        begin
          response = Net::HTTP.post_form(uri, {'logoutRequest' => logout_template})
          if response.kind_of? Net::HTTPSuccess
            puts "Logout notification successfully posted to #{self.service.inspect}."
            return true
          else
            puts "Service #{self.service.inspect} responed to logout notification with code '#{response.code}'!"
            return false
          end
        rescue Exception => e
          puts "Failed to send logout notification to service #{self.service.inspect} due to #{e}"
          return false
        end
      end


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

      def ticket_valid?
        self.consumed? == false
      end

    end
  end
end
