require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.3 /logout' do
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

  context '2.3 action ' do
    it 'must destroy the ticket-granting cookie' do
      login
      get '/logout'
      rack_mock_session.cookie_jar["tgt"].should_not == "valid-tgt"
    end

    it 'after destroying the ticket-granting cookie, subsequent requests to /login will not obtain service tickets' do
      login
      # response.body.should_not include("please login") TODO: Comeback

      get '/logout'
      rack_mock_session.cookie_jar["tgt"].should_not == "valid-tgt"

      get '/login'
      response.body.should include("please login")
    end
  end

  context '2.3.1 Parameters' do
    it 'must accept the url param' do
      url = CGI.escape("http://www.go-back.edu")
      get '/logout', {:url => url}
      response.body.should include("The application you just logged out from has provided a link it would like you to follow. Please click here to access #{CGI.unescape(url)}")
    end
  end

  context '2.3.2 Response' do
    it 'must display a page stating the user has been logged out' do
      get '/logout'
      response.body.should include("You've successfully logged out")
    end
  end
end
