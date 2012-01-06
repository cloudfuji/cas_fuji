require 'spec_helper'

describe "LogoutNotifier" do
  subject { LogoutNotifier }

  describe ".perform" do
    it "should send a logout notification to each of those logout tickets" do
      service_ticket_klass = ::CasFuji::Models::ServiceTicket
      
      service_tickets = []
      3.times do |i|
        service_ticket = service_ticket_klass.new
        service_ticket.should_receive(:notify_logout!)
        service_tickets << service_ticket
      end
      
      query_object = Object.new
      service_ticket_klass.should_receive(:where).and_return(query_object)
      query_object.should_receive(:all).and_return(service_tickets)

      subject.perform(12)
    end
  end
end   
