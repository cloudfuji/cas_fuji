require 'spec_helper'

describe LoginTicket do

  describe "generate" do
    it "should generate a new LoginTicket and save it to the database" do
      expect {
        LoginTicket.generate("test_client_hostname")
      }.to change(LoginTicket, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      LoginTicket.generate("test_client_hostname").name.should =~ /LT-.+/
    end
  end

  describe "valid?" do
    it "should return the ticket if the ticket name is valid" do
      login_ticket = LoginTicket.generate("test_client_hostname")
      LoginTicket.valid?(login_ticket.name).should be_kind_of(LoginTicket)
    end

    it "should return nil if the ticket name is not valid" do
      LoginTicket.valid?("test_login_ticket").should be_nil
    end
  end

  describe "consume" do
    it "should mark the LoginTicket as consumed" do
      login_ticket = LoginTicket.generate("test_client_hostname")
      LoginTicket.consume(login_ticket.name)
      LoginTicket.find_by_name(login_ticket.name).should_not be_nil
    end
  end

end
