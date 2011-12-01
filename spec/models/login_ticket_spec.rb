require 'spec_helper'

describe "LoginTicket" do

  describe "generate" do
    it "should generate a new LoginTicket and save it to the database" do
      expect {
        CasFuji::Models::LoginTicket.generate("test_client_hostname")
      }.to change(CasFuji::Models::LoginTicket, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      CasFuji::Models::LoginTicket.generate("test_client_hostname").name.should =~ /LT-.+/
    end
  end

  describe "valid?" do
    it "should return the ticket if the ticket name is valid" do
      login_ticket = CasFuji::Models::LoginTicket.generate("test_client_hostname")
      CasFuji::Models::LoginTicket.valid?(login_ticket.name).should be_kind_of(CasFuji::Models::LoginTicket)
    end

    it "should return nil if the ticket name is not valid" do
      CasFuji::Models::LoginTicket.valid?("test_login_ticket").should be_nil
    end
  end

  describe "consume" do
    it "should mark the LoginTicket as consumed" do
      login_ticket = CasFuji::Models::LoginTicket.generate("test_client_hostname")
      CasFuji::Models::LoginTicket.consume(login_ticket.name)
      CasFuji::Models::LoginTicket.find_by_name(login_ticket.name).should_not be_nil
    end
  end

end
