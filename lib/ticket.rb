module Ticket
  def self.included(mod)
    mod.extend(ClassMethods)
  end

  module ClassMethods
    def unique_ticket_name(ticket_type)
      "#{ ticket_type.upcase }-#{ ::UUID.new.generate }"
    end
  end
end
