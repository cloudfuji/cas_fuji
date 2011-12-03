module CasFuji
  module Models
    class BaseTicket < ActiveRecord::Base

      self.abstract_class = true
      establish_connection(CasFuji.config[:database])

      def self.unique_ticket_name(ticket_type)
        "#{ ticket_type.upcase }-#{ ::UUID.new.generate }"
      end

      def self.cleanup(max_lifetime, max_unconsumed_lifetime)
        transaction do
          conditions = ["created_on < ? OR (consumed IS NULL AND created_on < ?)",
                        Time.now - max_lifetime,
                        Time.now - max_unconsumed_lifetime]

          expired_tickets_count = count(:conditions => conditions)

          # Do we have a global $LOG object, or is this just leftover?
          $LOG.debug("Destroying #{expired_tickets_count} expired #{self.name.demodulize}"+
                     "#{'s' if expired_tickets_count > 1}.") if expired_tickets_count > 0

          destroy_all(conditions)
        end
      end

      def consume!
        self.consumed = Time.now
        self.save!
      end

    end
  end
end
