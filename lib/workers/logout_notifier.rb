class LogoutNotifier
  @queue = :logout_notifier

  def self.perform(ticket_granting_ticket_id)
    service_tickets = ::CasFuji::Models::ServiceTicket.where("ticket_granting_ticket_id = ? and logged_out = ?", ticket_granting_ticket_id, false).all
    service_tickets.each do |service_ticket|
      service_ticket.notify_logout!
    end
  end

end
