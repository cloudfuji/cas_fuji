require File.expand_path("#{Dir.pwd}/spec/spec_helper")

describe 'CasProtocol 2.1 /login as a credential requestor [GET]' do
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
    end

  context 'in general' do
    context 'without a session' do
      it 'requests credentials from user to initiate a sso session' do
        get '/login', {}, {'rack.session' => @no_session}
        response.body.should include('please login')
      end
    end
  end

  context 'dealing with the service params' do
    it 'should be present' do
      get '/login'
      response.status.should == 200
    end

    it 'should accept the service param' do
      get '/login', :service => @valid_service_target
      response.status.should == 200
    end

    it 'should enforce that the service param is URL-encoded as per RFC 1738' do
      get '/login', :service => '1!@#$1234_?()'
      pending "In app.rb a check for URL format prefix is to be implemented; Which is unnecessary since wrong urls will anyway fail"
      #response.body.should include("Sorry, that doesn't look like a valid service param")
    end

    context 'with a session' do 
      it 'notifies the user that is is already logged in if there is no service param' do
        get '/login', {}, {'rack.session' => @session}
        response.body.should include("you're already logged in")
      end
    end
  end

  context 'dealing with the renew param' do
    it 'should accept the renew param' do
      get '/login', :renew => true
      response.status.should == 200
    end

    it 'forces the client to present credentials if renew param is present' do
      get '/login?renew=true', {}, {'rack.session' => @session}
      response.body.should include('please login')
    end

    it 'should ignore the gateway param is the renew param is set' do
      get '/login?renew=true', {}, {'rack.session' => @session}
      response.body.should include('please login')
    end
  end

  context 'dealing with the gateway param' do 
    it 'should accept the gateway and service param by redirecting' do
      get '/login', {:gateway => true, :service => @valid_service_target}
      response.status.should == 302
    end

    context 'with a session' do
      it 'should should redirect to the service url with a valid service ticket' do
        get "/login", {:gateway => true, :service => @valid_service_target}, {'rack.session' => @session}

        response.status.should == 302
        uri = Addressable::URI.parse(response.headers["Location"])
        uri.query_values["ticket"].should == "valid"
      end
    end

    context 'without a session' do
      it 'should redirect to the service url *without* a ticket param if non-interactive authentication cannot be established' do
        get "/login?gateway=true&service=#{@valid_service_target}", {}, {'rack.session' => @no_session}

        response.status.should == 302
        uri = Addressable::URI.parse(response.headers["Location"])
        uri.query_values.should be_nil
      end
    end

    it 'should act is if there are no parameters present if gateway is specified and service is not' do
      get '/login', :gateway => true, 'rack.session' => @session
      pending 'What does this look like?'
    end
  end

  context '2.1.3 response for username/password authentication' do
    it 'must include a form with the parameters: "username", "password", and "lt"' do
      get '/login'
      response.body.should include "username"
      response.body.should include "password"
      response.body.should include "lt"
    end

    it 'if the service param was specified, the form must include a form with the parameters: "username", "password", "service", and "lt"' do
      get '/login', :service => @valid_service_target
      response.body.should include "username"
      response.body.should include "password"
      response.body.should include "service"
      response.body.should include "lt"
    end

    it 'if the service param was specified, the form must include a form with the "service" field containing the value originally passed in' do
      get '/login', :service => @valid_service_target
      response.body.should include "service"
      response.body.should include @valid_service_target
    end


    it 'the form must be submitted to /login via POST' do
      get '/login', :service => @valid_service_target
      response.body.should include 'action="/cas/login"'
      response.body.should include 'method="post"'
    end
  end    
end

