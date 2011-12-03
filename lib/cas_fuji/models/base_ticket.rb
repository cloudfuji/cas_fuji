module CasFuji
  module Models
    class BaseTicket < ActiveRecord::Base

      if ::ActiveRecord::Base.connected?
        establish_connection(CasFuji.config[:database])
      else
        ::ActiveRecord::Base.establish_connection(CasFuji.config[:database])
      end

      def self.unique_ticket_name(ticket_type)
        "#{ ticket_type.upcase }-#{ ::UUID.new.generate }"
      end

    end
  end
end
