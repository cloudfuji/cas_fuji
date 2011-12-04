require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasAuthorizer' do
  include Rack::Test::Methods

  def app
    CasFuji::App
  end

  def response
    last_response
  end

  def authorizer
    CasFuji::Authorizer
  end

  def login
    post '/login', {:username => @valid_username, :password => @valid_password, :lt => @valid_login_ticket, :service => @valid_service_target}
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

  context 'when a user is authorized' do
    it 'it should redirect them' do
      CasFuji::Authorizer.should_receive(:authorized?).with('test_permanent_id', @valid_service_target).and_return(true)
      login
    end
  end

  context 'when a user is not authorized' do
    it 'should not redirect them' do 
      CasFuji::Authorizer.should_receive(:authorized?).with('test_permanent_id', @valid_service_target).and_return(false)
      login
      response.should_not be_redirect
    end

    it 'should display an error page explaining to the user they are not authorized' do
      CasFuji::Authorizer.stub(:authorized?).and_return(false)
      login
      response.should_not be_redirect
    end
  end
end
