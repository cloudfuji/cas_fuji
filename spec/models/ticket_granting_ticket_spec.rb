require "spec_helper"

describe "TicketGrantingTicket" do

  subject { ::CasFuji::Models::TicketGrantingTicket }

  describe "associations" do
    it "should have many service tickets" do
      subject.new.respond_to? :service_tickets
    end
  end

  describe "validate_ticket" do
    it "should return the TicketGrantingTicket if valid ticket" do
      tgt = subject.new
      subject.should_receive(:find_by_name).and_return(tgt)
      tgt.should_receive(:try).with(:expired?).and_return(false)

      subject.validate_ticket("sample_ticket").should be_true
    end

    it "should return nil if the TicketGrantingTicket is not found" do
      subject.should_receive(:find_by_name).and_return(nil)
      subject.validate_ticket("sample_ticket").should be_nil
    end

    it "should return nil if the TicketGrantingTicket has expired" do
      tgt = subject.new
      subject.should_receive(:find_by_name).and_return(tgt)
      tgt.should_receive(:try).with(:expired?).and_return(true)
      subject.validate_ticket("sample_ticket").should be_nil
    end
  end

  describe "generate" do
    it "should generate new TicketGrantingTicket" do
      valid_permanent_id = "test_pid"
      client_hostname    = "Cloudfuji.local"
      test_authenticator = "CasFuji::Authenticators::TestAuth"

      expect {

        subject.generate(
          client_hostname,
          test_authenticator,
          valid_permanent_id
          )

      }.to change(subject, :count).by(1)
    end
  end

end
