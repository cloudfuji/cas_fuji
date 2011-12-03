require 'spec_helper'

describe "ServiceTicket" do

  before :each do
    @valid_service      = "http://target-service.com/service_url"
    @valid_permanent_id = "test_pid"
    @client_hostname    = "Bushido.local"
    @test_authenticator = "CasFuji::Authenticators::TestAuth"

    @service_ticket = CasFuji::Models::ServiceTicket.generate(
      @test_authenticator,
      @valid_service,
      @valid_permanent_id,
      @client_hostname)
  end

  describe "Default values" do
    it "should have consumed as nil on new ticket creation" do
      @service_ticket.consumed.should be_nil
    end
  end
  
  describe "generate" do
    it "should generate a new ServiceTicket and save it to the database" do
      expect {
        CasFuji::Models::ServiceTicket.generate(
          @test_authenticator,
          @valid_service,
          @valid_permanent_id,
          @client_hostname)
      }.to change(CasFuji::Models::ServiceTicket, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      @service_ticket.name.should =~ /ST-.+/
    end
  end

  describe "not_consumed?" do
    it "should return true if it's not been consumed" do
      @service_ticket.not_consumed?.should be_true
    end

    it "should return false if it's been consumed" do
      st = CasFuji::Models::ServiceTicket.generate(
        @test_authenticator,
        @valid_service,
        @valid_permanent_id,
        @client_hostname)
      st.consume!

      st.not_consumed?.should be_false
    end
  end

  describe "consumed?" do
    it "should should return false if it's not been consumed" do
      @service_ticket.consumed?.should be_false
    end

    it "should should return true if it's been consumed" do
      st = CasFuji::Models::ServiceTicket.generate(
        @test_authenticator,
        @valid_service,
        @valid_permanent_id,
        @client_hostname)
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
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket(nil, @valid_ticket)
      error.should_not be_nil
      error.should == :INVALID_REQUEST
    end

    it "should return the proper error symbol with a missing ticket" do
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket(@valid_service, nil)
      error.should_not be_nil
      error.should == :INVALID_REQUEST
    end

    it "should return the proper error symbol for an invalid ticket" do
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket(@valid_service, "invalid-ticket")
      error.should_not be_nil
      error.should == :INVALID_TICKET
    end

    it "should return the proper error symbol for a consumed ticket" do
      @service_ticket.consume!
      CasFuji::Models::ServiceTicket.should_receive(:find_by_name).with(@service_ticket.name).and_return(@service_ticket)
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket(@valid_service, @service_ticket.name)
      error.should_not be_nil
      error.should == :INVALID_TICKET
    end

    it "should return the proper error symbol with an invalid service for a valid ticket" do
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket("invalid-service", @service_ticket.name)
      error.should_not be_nil
      error.should == :INVALID_SERVICE
    end

    it "should return a valid, unconsumed ticket when given valid params" do
      error, message, ticket = CasFuji::Models::ServiceTicket.validate_ticket(@valid_service, @service_ticket.name)
      error.should be_nil
      ticket.should_not be_nil
      ticket.ticket_valid?.should be_true
    end
  end

end
