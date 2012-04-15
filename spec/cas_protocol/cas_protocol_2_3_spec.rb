require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.3 /logout' do
  include Rack::Test::Methods

  class Resque
    def self.enqueue
    end
  end
  
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

    @session                = {:user => 123}
    @no_session             = {}
    @valid_service_target   = CGI.escape('http://target-service.com/service_url')
    @valid_service_uri      = Addressable::URI.parse('http://target-service.com/service_url')
    @valid_username         = "test_username"
    @valid_password         = "test_password"
    @valid_login_ticket     = "test_login_ticket"

    @client_hostname        = "Cloudfuji.local"

    @invalid_service_target = nil
    @invalid_service_uri    = nil
    @invalid_username       = nil
    @invalid_password       = nil
    @invalid_login_ticket   = nil

    post '/login', {:username => @valid_username, :password => @valid_password, :lt => CasFuji::Models::LoginTicket.generate(@client_hostname).name}
    rack_mock_session.cookie_jar["tgt"].should =~ /\ATGT-[a-zA-Z0-9\-]+\Z/

    Net::HTTP.stub!(:post_form).and_return(Object.new)
  end

  context '2.3 action ' do
    it 'must destroy the ticket-granting cookie' do
      login
      Resque.should_receive(:enqueue)
      get '/logout'

      rack_mock_session.cookie_jar["tgt"].should be_blank
    end

    it 'must queue logout notifications' do
      login
      Resque.should_receive(:enqueue)
      get '/logout'
    end

    it 'after destroying the ticket-granting cookie, subsequent requests to /login will not obtain service tickets' do
      get '/login', {:gateway => true, :service => @valid_service_target}
      last_response.should be_redirect

      Resque.should_receive(:enqueue)
      get '/logout'
      rack_mock_session.cookie_jar["tgt"].should be_blank

      get '/login'
      response.body.should include("please login")
    end
  end

  context '2.3.1 Parameters' do
    it 'must accept the url param' do
      url = CGI.escape("http://www.go-back.edu")
      Resque.should_receive(:enqueue)
      get '/logout', {:url => url}

      response.body.should include("The application you just logged out from has provided a link it would like you to follow. Please click here to access #{CGI.unescape(url)}")
    end
  end

  context '2.3.2 Response' do
    it 'must display a page stating the user has been logged out' do
      Resque.should_receive(:enqueue)
      get '/logout'

      response.body.should include("You've successfully logged out")
    end
  end
end
