require 'spec_helper'

describe "LogoutNotifier" do
  subject { LogoutNotifier }

  before :each do
    @service_ticket_klass = ::CasFuji::Models::ServiceTicket    
    @service_tickets = []
  end

  describe ".perform" do
    it "should *not* call the method if it's an invalid command" do
      LogoutNotifier.should_not_receive(:invalid_command)
      LogoutNotifier.perform({"command" => "invalid_command"})
    end

    it "should call the method if it's a valid command" do
      LogoutNotifier.should_receive(:logout)
      LogoutNotifier.perform({"command" => "logout"})
    end
  end
  
  describe ".logout_all" do
    it "should send a logout notification to each of those service tickets" do
      ticket_granting_ticket_id = 12
      query_object = Object.new
      @service_ticket_klass.should_receive(:where).
        with("ticket_granting_ticket_id = ? and logged_out = ?", ticket_granting_ticket_id, false).
        and_return(query_object)

      3.times do |i|
        service_ticket = @service_ticket_klass.new
        service_ticket.should_receive(:notify_logout!)
        @service_tickets << service_ticket
      end

      query_object.should_receive(:all).and_return(@service_tickets)
      subject.logout_all({'command' => 'logout_all', 'ticket_granting_ticket_id' => ticket_granting_ticket_id})
    end
  end


  describe ".logout" do
    it "should send logout notifications to each app for a specific permanent_id and service_url" do

      permanent_id = 12
      service_url  = "https://example.com/users/service"
      
      query_object = Object.new
      @service_ticket_klass.should_receive(:where).
        with({
          :service      => service_url,
          :permanent_id => permanent_id,
          :logged_out   => false
        }).and_return(query_object)

      3.times do |i|
        service_ticket = @service_ticket_klass.new
        service_ticket.should_receive(:notify_logout!)
        @service_tickets << service_ticket
      end

      query_object.should_receive(:all).and_return(@service_tickets)
      subject.logout({
          'command'      => 'logout',
          'permanent_id' => permanent_id,
          'service_url'  => service_url})
    end
  end

end   
