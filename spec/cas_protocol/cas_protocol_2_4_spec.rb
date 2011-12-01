require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.4 /validate' do
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

    st = CasFuji::Models::ServiceTicket.generate(@valid_service_target, @valid_permanent_id, @client_hostname)

    @valid_service_ticket = st.name

    @invalid_service_target = nil
    @invalid_service_uri    = nil
    @invalid_username = nil
    @invalid_password = nil
    @invalid_login_ticket = nil

    @failure_response = "no<LF><LF>"
  end

  context '2.4 action ' do
    it 'checks the validity of a service ticket' do
      
    end
  end

  context '2.4.1 Parameters' do
    it 'must have the service param' do
      get '/validate', {:ticket => @valid_service_ticket}

      response.status.should == 401
      response.body.should == @failure_response
    end

    it 'must have the ticket param' do
      get '/validate', {:service => @valid_service_target}

      response.status.should == 401
      response.body.should == @failure_response
    end
  end

  context '2.4.2 Response' do
    context 'on service ticket validation success' do
      it 'must return yes<LF>username<LF>' do
        
        
        get '/validate', {:service => @valid_service_target, :ticket => @valid_service_ticket}
        
        response.body.should =~ /yes<LF>#{@valid_permanent_id}<LF>/
      end
    end

    context 'on service ticket validation failure' do
      it 'must return no<LF><LF>' do
        get '/validate', {:service => @invalid_service_target, :ticket => @invalid_service_ticket}

        response.body.should =~ /no<LF><LF>/
      end
    end
  end
end
