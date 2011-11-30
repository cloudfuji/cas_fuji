require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.5 /serviceValidate' do
  include Rack::Test::Methods

  def app
    CasFuji::App
  end

  def response
    last_response
  end

  def login
    post '/login', {:username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket}
  end

  before(:each) do
    clear_cookies

    @session = {:user => 123}
    @no_session = {}
    @valid_service_target = CGI.escape('http://target-service.com/service_url')
    @valid_service_uri    = Addressable::URI.parse('http://target-service.com/service_url')
    @valid_permanent_id = "valid_permanent_id"
    @valid_username = "valid_username"
    @valid_password = "valid_password"
    @valid_login_ticket = "test_login_ticket"
    @client_hostname = "Bushido.local"

    st = ServiceTicket.generate(@valid_service_target, @valid_permanent_id, @client_hostname)
    
    @valid_service_ticket = st.name

    @invalid_service_target = CGI.escape("http://invalid-service-target.com")
    @invalid_service_uri    = Addressable::URI.parse('http://invalid-service-target.com/service_url')
    @invalid_username = nil
    @invalid_password = nil
    @invalid_login_ticket = nil
    @invalid_service_ticket = "invalid_service_ticket"

    @failure_response = "no<LF><LF>"
  end

  context '2.5 action ' do
    it 'checks the validity of a valid service ticket' do
      get '/serviceValidate', {:service => @valid_service_target, :ticket => @valid_service_ticket}

      xml = Nokogiri.XML(response.body)
      xml.xpath('/serviceResponse/authenticationSuccess/user').inner_text.should == @valid_permanent_id
    end

    it 'checks the validity of a invalid service ticket' do
      get '/serviceValidate', {:service => @valid_service_target, :ticket => @invalid_service_ticket}

      xml = Nokogiri.XML(response.body)

      node = xml.xpath('/serviceResponse/authenticationFailure')
      node.attr('code').inner_text.should == 'INVALID_TICKET'
    end
  end

  context '2.5.1 Parameters' do
    it 'must have the service param' do
      get '/serviceValidate', {:ticket => @valid_service_ticket}

      xml = Nokogiri.XML(response.body)

      node = xml.xpath('/serviceResponse/authenticationFailure')
      node.attr('code').inner_text.should == 'INVALID_REQUEST'
      node.inner_text.should include("Service is required")
    end

    it 'must have a valid service param' do
      get '/serviceValidate', {:service => @invalid_service_target, :ticket => @valid_service_ticket}

      xml = Nokogiri.XML(response.body)

      node = xml.xpath('/serviceResponse/authenticationFailure')

      node.attr('code').inner_text.should == 'INVALID_SERVICE'
      node.inner_text.should include("Invalid service")

      # CAS MUST invalidate the ticket and disallow future validation of that same ticket
      pending "ticket.should_be invalid?"
    end

    it 'must have the ticket param' do
      get '/serviceValidate', {:service => @valid_service_target}

      xml = Nokogiri.XML(response.body)

      node = xml.xpath('/serviceResponse/authenticationFailure')
      node.attr('code').inner_text.should == 'INVALID_REQUEST'
      node.inner_text.should include("Ticket is required")
    end

    it 'must have a valid ticket param' do
      get '/serviceValidate', {:service => @valid_service_target, :ticket => @invalid_service_ticket}

      xml = Nokogiri.XML(response.body)

      node = xml.xpath('/serviceResponse/authenticationFailure')
      node.attr('code').inner_text.should == 'INVALID_TICKET'
      node.inner_text.should include("Invalid ticket")
    end
  end

  context '2.5.2 Response' do
    context 'on service ticket validation success' do
    end

    context 'on service ticket validation failure' do
    end
  end
end
