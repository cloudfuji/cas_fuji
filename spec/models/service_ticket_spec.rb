require 'spec_helper'

describe ServiceTicket do

  describe "generate" do
    it "should generate a new ServiceTicket and save it to the database" do
      expect {
        ServiceTicket.generate("test_service", "test_username")
      }.to change(LoginTicket, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      ServiceTicket.generate("test_service", "test_username").name.should =~ /ST-.*/
    end
  end

  describe "valid" do
    it "should should return the ServiceTicket if it exists" do
      st = ServiceTicket.generate("test_service", "test_username")
      ServiceTicket.valid?("test_service", "test_username", st.name).should be_kind_of(ServiceTicket)
    end
  end

end
