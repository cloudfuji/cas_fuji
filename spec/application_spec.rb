require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CasFuji do
  include Rack::Test::Methods

  def app
    CasFuji::App
  end

  def current_app
    rack_mock_session.instance_variable_get("@app")
  end

  def response
    last_response
  end

  class DummyAuthenticator
    def self.validate(params)
      return 'permanent_id' if params[:username] == "valid" and params[:password] == "valid"
      return nil
    end
  end

  def untested_methods
    []
  end

  it 'should run a simple test' do
    app.should_not be_nil
  end

  context 'helper methods' do
    context 'requires_params' do
      it 'should add a requirement for the current given route and add to @errors if param is missing' do
        # This is dangerous, it'll persist against all the future tests, so be sure to undo it
        app.class_eval do
          alias :old_set_request_variables! :set_request_variables! 

          define_method :set_request_variables! do
            @errors = []
            @required_param = params[:required_param] unless params[:required_param].nil?
          end
        end

        app.instance_eval do
          get '/test' do
            requires_params({:required_param => "Some-Required-Param"})

            halt 400, @errors.join(" ") unless @errors.empty?
            halt 200, 'success'
          end
        end

        get '/test', {}
        response.body.should == "Some-Required-Param is required"

        get '/test', {:required_param => 'happiness is required'}
        response.body.should == "success"

        # Undo the dangerous alias we did
        app.class_eval do
          alias :set_request_variables! :old_set_request_variables! 
        end
      end
    end

    context 'current_user' do
      # I can't get a handle to the current app at all, so we can't stub out the
      # app. Each rack request creates a new instance of @app, and there's no
      # way to assert ahead of time what we want to happen on that object,
      # unless we stub very, very deep.

      # it 'should return the current user if session[user] is present' do
      #   current_app.should_receive(:current_user).and_return(123)
      #   get '/login', {}, {:user => 123, 'REMOTE_HOST' => 'casfuji.local'}
      # end
      # 
      # it 'should return nil if session[user] is absent' do
      #   current_app.should_receive(:current_user).and_return(123)
      #   get '/login', {}, {'REMOTE_HOST' => 'casfuji.local'}
      # end
    end

    context 'append_ticket_to_url' do
      it 'should take a service url and append the ticket as a param' do
        url = "http://casfuji.gobushido.com/users/service"
        ticket = "service-ticket-name"

        result = ::Addressable::URI.parse(CasFuji::App.append_ticket_to_url(url, ticket))
        result.query_values["ticket"].should == ticket
      end
    end

    context 'authenticated_user' do
      it 'should return a permanent id if credentials were valid' do
        CasFuji.should_receive(:config).and_return({:authenticators => [{'class' => "DummyAuthenticator"}]})
        CasFuji::App.authenticate_user!("valid", "valid").should == "permanent_id"
      end

      it 'should return nil if password is invalid' do
        CasFuji.should_receive(:config).and_return({:authenticators => [{'class' => "DummyAuthenticator"}]})
        CasFuji::App.authenticate_user!("valid", "invalid").should be_nil
      end

      it 'should return nil if username is invalid' do
        CasFuji.should_receive(:config).and_return({:authenticators => [{'class' => "DummyAuthenticator"}]})
        CasFuji::App.authenticate_user!("invalid", "valid").should be_nil
      end
    end

    context 'valid_ticket?' do
      before(:each) do
        @valid_ticket = ::CasFuji::Models::ServiceTicket.generate(CGI.escape('http://casfuji.gobushido.com/users/service'),
                                               'permanent-id',
                                               '127.0.0.1')
      end

      it 'should return false if ticket it nill' do
        CasFuji::App.valid_ticket?(nil).should be_false
      end

      it 'should return false if ticket is consumed' do
        @valid_ticket.consume!
        CasFuji::App.valid_ticket?(@valid_ticket).should be_false
      end

      it 'should return true if ticket is valid and not consumed' do
        CasFuji::App.valid_ticket?(@valid_ticket).should be_true
      end
      
    end

    context 'untested methods' do
      it 'should be completely empty' do
        untested_methods.should be_empty
      end
    end
  end
end
