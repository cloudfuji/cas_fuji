# CAS 3.1
module CasFuji
  module Models
    class ServiceTicket < CasFuji::Models::BaseTicket
      # begins with "ST-"
      # Services MUST be able to accept ServiceTickets
      # up to 32 characters, but it's RECOMMENDED they
      # accept up to 256 characters
      set_table_name "casfuji_st"
      belongs_to :ticket_granting_ticket

      attr_accessible :name, :authenticator, :permanent_id, :service, :client_hostname, :ticket_granting_ticket_id
      
      def self.generate(authenticator, service, permanent_id, client_hostname, ticket_granting_ticket_id)
        CasFuji::Models::ServiceTicket.create(
          :authenticator   => authenticator,
          :name            => unique_ticket_name("ST"),
          :permanent_id    => permanent_id,
          :service         => service,
          :client_hostname => client_hostname,
          :ticket_granting_ticket_id => ticket_granting_ticket_id)
      end

      def self.validate_ticket(service_url, ticket_name)
        return [:INVALID_REQUEST, "Ticket is required"] if ticket_name.nil?
        return [:INVALID_REQUEST, "Service is required"] if service_url.nil?

        ticket = self.find_by_name(ticket_name)

        return [:INVALID_TICKET, "Invalid ticket"] if ticket.nil? or not ticket.ticket_valid?
        return [:INVALID_SERVICE, "Service does not match ticket"] if not ticket.service_valid?(service_url)

        return [nil, "Ticket and service are valid", ticket]
      end


      def logout_template
        time = Time.now
        %{<samlp:LogoutRequest ID="#{self.id}" Version="2.0" IssueInstant="#{time.rfc2822}">
          <saml:NameID></saml:NameID>
          <samlp:SessionIndex>#{self.name}</samlp:SessionIndex>
          </samlp:LogoutRequest>}
      end


      def logout_via_authenticator
        authenticator_klass = self.authenticator.constantize
        return authenticator_klass.logout!(self) if authenticator_klass.respond_to? :logout!
        false
      end


      def notify_logout!
        return self.logout! if self.logout_via_authenticator || self.logout_via_cas
        false
      end


      def logout_via_cas
        begin
          response = Net::HTTP.post_form(self.service_uri, {'logoutRequest' => self.logout_template})
          return response.kind_of?(Net::HTTPSuccess)
        rescue Exception => e
          puts "Failed to send logout notification to service #{self.service.inspect} due to #{e}"
          return false
        end
      end

      def consumed?
        not self.consumed.nil?
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

      def service_uri
        uri = URI.parse(self.service)
        uri.path = '/' if uri.path.empty?
        return uri
      end

      def logout!
        self.logged_out = true
        self.save
      end

    end
  end
end
