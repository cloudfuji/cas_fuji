require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.6 /proxyValidate' do
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
    @valid_service_ticket = "test_service_ticket"

    @invalid_service_target = CGI.escape("http://invalid-service-target.com")
    @invalid_service_uri    = Addressable::URI.parse('http://invalid-service-target.com/service_url')
    @invalid_username = nil
    @invalid_password = nil
    @invalid_login_ticket = nil
    @invalid_service_ticket = "invalid_service_ticket"

    @failure_response = "no<LF><LF>"
  end

  context '2.6 action ' do
    
  end
end
