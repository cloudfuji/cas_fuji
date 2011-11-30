require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.2 /login as a credential acceptor [POST]' do
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
    @valid_username = "test_username"
    @valid_password = "test_password"
    @valid_login_ticket = "test_login_ticket"

    @invalid_service_target = nil
    @invalid_service_uri    = nil
    @invalid_username = nil
    @invalid_password = nil
    @invalid_login_ticket = nil
  end

  context '2.2.1 Parameters common to all type of authentication' do
    it 'may accept the service param' do
      post '/login', :service => @valid_service_target
      pending 'This is discussed in detail in 2.2.4, might not need this spec'
    end

    it 'must *not* redirect the user to the service immediately after success authentication if the warn param is present' do

      LoginTicket.should_receive(:consume).with(@valid_login_ticket)
      
      post '/login', {:service => @valid_service_target, :username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket, :warn => true}, {"REMOTE_HOST" => "Bushido.local"}
      last_response.body.should include("you are about to be redirected to #{CGI.unescape(@valid_service_target)}, is that ok?")
    end
  end

  context '2.2.2 Parameters for username/password authentication' do
    it 'must require the username param while it is acting as a credential acceptor for username/password authentication' do
      post '/login', {:service => @valid_service_target}
      response.body.should include("Username is required")
    end

    it 'must require the password param while it is acting as a credential acceptor for username/password authentication' do
      post '/login', {:service => @valid_service_target}
      response.body.should include("Password is required")
    end

    it 'must require the lt param while it is acting as a credential acceptor for username/password authentication' do
      post '/login', {:service => @valid_service_target}
      response.body.should include("Login ticket is required")
    end
  end

  context '2.2.4 response when operating as a credential acceptor' do
    context 'on successful login' do 
      it 'redirect to the service target if service param present' do
        post '/login', {:service => @valid_service_target, :username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket}

        uri = Addressable::URI.parse(last_response.headers["Location"])
        uri.scheme.should == @valid_service_uri.scheme
        uri.host.should   == @valid_service_uri.host
        uri.path.should   == @valid_service_uri.path
        uri.query_values["ticket"].should =~ /ST-.+/
      end

      it 'displays a message to the client that is has successful initiated a sso session' do
        post '/login', {:username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket}

        response.body.should include("Successfully logged in")
      end
    end

    context 'on failed login' do
      it '' do
        post '/login', {:username => @invalid_username, :password => @invalid_password, :lt => @invalid_login_ticket}

        response.body.should_not include("Successfully logged in")
        response.body.should include 'action="/login"'
        response.body.should include 'method="post"'
      end
    end
  end
end
