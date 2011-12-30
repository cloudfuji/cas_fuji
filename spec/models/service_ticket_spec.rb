require 'spec_helper'

describe "ServiceTicket" do

  subject { CasFuji::Models::ServiceTicket }
  
  before :each do
    @valid_service      = "http://target-service.com/service_url"
    @valid_permanent_id = "test_pid"
    @client_hostname    = "Bushido.local"
    @test_authenticator = "CasFuji::Authenticators::TestAuth"

    @tgt = CasFuji::Models::TicketGrantingTicket.generate(
      @client_hostname,
      @test_authenticator,
      @valid_permanent_id)
    
    @service_ticket = subject.generate(
      @test_authenticator,
      @valid_service,
      @valid_permanent_id,
      @client_hostname, @tgt.id)
  end

  describe "default values" do
    it "should have consumed as nil on new ticket creation" do
      @service_ticket.consumed.should be_nil
    end

    it "should have logged_out as false by default" do
      @service_ticket.logged_out.should be_false
    end
  end

  describe "associations" do
    it "should belong to a TicketGrantingTicket" do
      @service_ticket.respond_to?(:ticket_granting_ticket).should be_true
    end
  end
  
  describe "generate" do
    it "should generate a new ServiceTicket and save it to the database" do
      expect {
        subject.generate(
          @test_authenticator,
          @valid_service,
          @valid_permanent_id,
          @client_hostname,
          @tgt.id)
      }.to change(subject, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      @service_ticket.name.should =~ /ST-.+/
    end
  end

  describe "consumed?" do
    it "should should return false if it's not been consumed" do
      @service_ticket.consumed?.should be_false
    end

    it "should should return true if it's been consumed" do
      st = subject.generate(
        @test_authenticator,
        @valid_service,
        @valid_permanent_id,
        @client_hostname,
        @tgt.id)
      st.consume!

      st.consumed?.should be_true
    end
  end

  describe "service_valid?" do
    it "should return true if the service is valid " do
      @service_ticket.service_valid?(@valid_service).should be_true
    end

    it "should return false if the service is not valid" do
      @service_ticket.service_valid?("invalid_service") == false
    end
  end

  describe "validate_ticket" do
    it "should return the proper error symbol with a missing service" do
      error, message, ticket = subject.validate_ticket(nil, @valid_ticket)
      error.should_not be_nil
      error.should == :INVALID_REQUEST
    end

    it "should return the proper error symbol with a missing ticket" do
      error, message, ticket = subject.validate_ticket(@valid_service, nil)
      error.should_not be_nil
      error.should == :INVALID_REQUEST
    end

    it "should return the proper error symbol for an invalid ticket" do
      error, message, ticket = subject.validate_ticket(@valid_service, "invalid-ticket")
      error.should_not be_nil
      error.should == :INVALID_TICKET
    end

    it "should return the proper error symbol for a consumed ticket" do
      @service_ticket.consume!
      subject.should_receive(:find_by_name).with(@service_ticket.name).and_return(@service_ticket)
      error, message, ticket = subject.validate_ticket(@valid_service, @service_ticket.name)
      error.should_not be_nil
      error.should == :INVALID_TICKET
    end

    it "should return the proper error symbol with an invalid service for a valid ticket" do
      error, message, ticket = subject.validate_ticket("invalid-service", @service_ticket.name)
      error.should_not be_nil
      error.should == :INVALID_SERVICE
    end

    it "should return a valid, unconsumed ticket when given valid params" do
      error, message, ticket = subject.validate_ticket(@valid_service, @service_ticket.name)
      error.should be_nil
      ticket.should_not be_nil
      ticket.ticket_valid?.should be_true
    end
  end

  describe "logout_via_authenticator" do
    it "should return false if the authenticator does not respond to logout! method" do
      @service_ticket.authenticator.constantize.should_receive(:respond_to?).and_return(false)

      @service_ticket.logout_via_authenticator.should be_false
    end

    describe "if the authenticator responds to logout" do
      before :each do
        @service_ticket.authenticator.constantize.should_receive(:respond_to?).and_return(true)
      end

      it "should return false if the authenticator.logout! returns false" do
        @service_ticket.authenticator.constantize.should_receive(:logout!).and_return(false)
        
        @service_ticket.logout_via_authenticator.should be_false
      end

      it "should return true authenticator.logout! returns true" do
        @service_ticket.authenticator.constantize.should_receive(:logout!).and_return(true)
        
        @service_ticket.logout_via_authenticator.should be_true
      end
    end
  end

  
  describe "service_url" do
    it "should return the unescaped service url" do
      @service_ticket.service_url.should == CGI.unescape(@service_ticket.service)
    end
  end

  describe "notify_logout!" do
    it "should return false if both logout via authenticator and CAS return false" do
      @service_ticket.should_receive(:logout_via_cas).and_return(false)
      @service_ticket.should_receive(:logout_via_authenticator).and_return(false)

      @service_ticket.notify_logout!.should be_false
    end

    describe "call self.logout!" do
      specify "if logout via CAS succeeds" do
        @service_ticket.should_receive(:logout_via_authenticator).and_return(false)
        @service_ticket.should_receive(:logout_via_cas).and_return(true)
        @service_ticket.should_receive(:logout!).and_return(true)

        @service_ticket.notify_logout!.should be_true
      end

      specify "if logout via authenticator succeeds" do
        @service_ticket.should_receive(:logout_via_authenticator).and_return(true)
        @service_ticket.should_not_receive(:logout_via_cas)
        @service_ticket.should_receive(:logout!).and_return(true)

        @service_ticket.notify_logout!.should be_true
      end
    end
  end

  describe "logout!" do
    it "should mark the ticket as logged out" do
      @service_ticket.logout!
      subject.find(@service_ticket.id).should be_true
    end
  end

  describe "logout_via_cas" do
    it "should return true if the response is a success" do
      response = Object.new

      Net::HTTP.should_receive(:post_form).
        with(@service_ticket.service_uri, {'logoutRequest' => @service_ticket.logout_template}).and_return(response)

      response.should_receive(:kind_of?).and_return(true)
      
      @service_ticket.logout_via_cas.should be_true
    end

    it "should return false if the response is a *not* a success" do
      response = Object.new

      Net::HTTP.should_receive(:post_form).
        with(@service_ticket.service_uri, {'logoutRequest' => @service_ticket.logout_template}).and_return(response)

      response.should_receive(:kind_of?).and_return(false)
      
      @service_ticket.logout_via_cas.should be_false
    end
  end
end
