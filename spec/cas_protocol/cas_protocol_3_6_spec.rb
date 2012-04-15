require File.expand_path("#{Dir.pwd}/spec/spec_helper")

# A Ticket-Granting Ticket is just a cookie that keeps track of
# whether the user is signed in to the CAS app itself. If so, then
# they don't have to re-enter their password into the CAS app every
# time they hit it. Though the terminology Ticket-Granting Ticket
# sounds big, it's really a very simple concept.

# Apps can explicitly deny a user from using a TGT by passing in the
# 'renew' param to the get /login form
describe 'CasProtocol 3.6 Ticket-Granting Ticket' do
  include Rack::Test::Methods

  def app
    CasFuji::App
  end

  def model
    CasFuji::Models::TicketGrantingTicket
  end

  def response
    last_response
  end

  def generate(ticket_name, client_hostname, authenticator, permanent_id)
    model.new(:name            => ticket_name,
              :permanent_id    => permanent_id,
              :authenticator   => authenticator,
              :client_hostname => client_hostname)
  end

  def login
    post '/login', {:username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket}
  end

  before(:each) do
    clear_cookies

    @session = {:user => 123}
    @no_session = {}
    @test_authenticator = "CasFuji::Authenticators::TestAuth"
    @valid_permanent_id = "valid_permanent_id"
    @valid_tgt = generate(model.unique_ticket_name('TGT'), 'Cloudfuji.local', @test_authenticator, @valid_permanent_id)
    @client_hostname = "Cloudfuji.local"
  end

  context 'in general' do
    it 'can only have characters from a-zA-Z0-0\-' do
      @valid_tgt.name = "TGT-invalid!"
      @valid_tgt.valid?.should be_false
    end

    it 'must begin with TGT-' do
      @valid_tgt.name = "invalid"
      @valid_tgt.valid?.should be_false
    end

    it 'should be valid if it begins with "TGT-" and ony contains alphanumberic characters' do
      @valid_tgt.name = "TGT-valid"
      @valid_tgt.valid?.should be_true
    end

    it 'should expire after a configurable point' do
      @valid_tgt.save
      model.validate_ticket(@valid_tgt.name).should be_true

      @valid_tgt.created_on = 100.years.ago
      @valid_tgt.save
      @valid_tgt.expired?.should be_true
    end

    it 'should be invalid after expiring' do
      @valid_tgt.save
      model.validate_ticket(@valid_tgt.name).should be_true

      @valid_tgt.created_on = 100.years.ago
      @valid_tgt.save
      model.validate_ticket(@valid_tgt.name).should be_false
    end
  end
end
