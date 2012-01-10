class LogoutNotifier
  @queue = :logout_notifier

  class << self
    def perform(params)
      valid_commands = [:logout, :logout_all]
      requested_command = params["command"].to_sym

      if valid_commands.include? requested_command
        self.send(requested_command, params)
      else
        puts "I don't know how to '#{requested_command}'"
      end
    end

    
    def logout(params)
      service_tickets = ::CasFuji::Models::ServiceTicket.where(
        :service      => params['service_url'],
        :permanent_id => params['permanent_id'],
        :logged_out   => false).all

      service_tickets.each do |service_ticket|
        service_ticket.notify_logout!
      end
    end


    def logout_all(params)
      ticket_granting_ticket_id = params['ticket_granting_ticket_id']
      service_tickets = ::CasFuji::Models::ServiceTicket.where("ticket_granting_ticket_id = ? and logged_out = ?", ticket_granting_ticket_id, false).all
      service_tickets.each do |service_ticket|
        service_ticket.notify_logout!
      end
    end

  end    
end
