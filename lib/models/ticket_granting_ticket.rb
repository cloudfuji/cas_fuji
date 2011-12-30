# CAS 3.5
module CasFuji
  module Models
    class TicketGrantingTicket < CasFuji::Models::BaseTicket
      # begins with "TGT-"
      set_table_name "casfuji_tgt"
      has_many :service_tickets

      attr_accessor :authenticator
      
      validates_format_of      :name, :with => /\ATGT-[\w|\-]+\Z/
      # This should be used, but it's causing problem with the db locally
      # validates_uniqueness_of  :name

      def self.validate_ticket(ticket_name)
        tgt = self.find_by_name(ticket_name)
        return tgt if tgt.try(:expired?) == false
      end

      def self.generate(client_hostname, authenticator, permanent_id)
        self.create(:name            => unique_ticket_name("TGT"),
                    :permanent_id    => permanent_id,
                    :authenticator   => authenticator,
                    :client_hostname => client_hostname)
      end

      def expired?
        (Time.now - created_on) > CasFuji.config[:ticket_granting_ticket][:session_length]
      end
    end
  end
end
