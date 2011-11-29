require 'spec_helper'

describe ServiceTicket do

  before :each do
    @valid_service      = "http://target-service.com/service_url"
    @valid_permanent_id = "test_pid"
    @valid_username     = "test_username"
    @client_hostname    = "Bushido.local"
  end
  
  describe "generate" do
    it "should generate a new ServiceTicket and save it to the database" do
      expect {
        ServiceTicket.generate(
          @valid_service,
          @valid_permanent_id,
          @valid_username,
          @client_hostname)
      }.to change(ServiceTicket, :count).by(1)
    end

    it "should generate a new LoginTicket with valid name" do
      ServiceTicket.generate(
          @valid_service,
          @valid_permanent_id,
          @valid_username,
          @client_hostname).name.should =~ /ST-.*/
    end
  end

  describe "valid" do
    it "should should return the ServiceTicket if it exists" do
      st = ServiceTicket.generate(
        @valid_service,
        @valid_permanent_id,
        @valid_username,
        @client_hostname)

      ServiceTicket.valid?(@valid_service, @valid_username, st.name).should be_kind_of(ServiceTicket)
    end
  end

end
