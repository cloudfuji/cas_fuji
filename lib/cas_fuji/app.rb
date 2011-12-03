class CasFuji::App < Sinatra::Base

  set :views, CasFuji.config[:templates][:path]

  before { set_request_variables! }

  ## ============================================================
  ## 
  ## CAS Implementation methods
  ##
  ## Remember the :before block that runs before each method
  ## and sets all of the needed variables for each request
  ##
  ## ============================================================

  # CAS 2.1
  get '/login' do
    redirect self.class.append_ticket_to_url(@service, "valid") if params[:gateway] and current_user and @service
    redirect @service                                           if params[:gateway]
    @messages << "you're already logged in as #{current_user}!" if current_user

    @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name

    erb 'login.html'.to_sym
  end

  # CAS 2.2
  post '/login' do
    puts "Well here we are: #{params.inspect}"
    requires_params({:username => "Username", :password => "Password", :lt => "Login ticket"})

    # Mark the login ticket as consumed if it's a valid login ticket
    ::CasFuji::Models::LoginTicket.consume(@lt) if @lt

    authenticator, permanent_id = self.class.authenticate_user!(params[:username], params[:password]) if @errors.empty?
    @errors << "Invalid username and password" if permanent_id.nil?

    halt(401, erb('login.html'.to_sym)) if not @errors.empty?

    # TODO refactor this. LoginTicket is being generated twice in this action
    if not @errors.empty?
      @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
      halt(401, erb('login.html'.to_sym))
    end

    if @service and @errors.empty?
      st = ::CasFuji::Models::ServiceTicket.generate(authenticator, @service, permanent_id, @client_hostname)
      response.set_cookie('tgt', tgt.to_s)
      halt(200, erb('redirect_warn.html'.to_sym)) if params[:warn]
      redirect self.class.append_ticket_to_url(st.service_url, st.name)
    end

    @messages << "Successfully logged in"

    @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
    halt(200, erb('login.html'.to_sym))
  end

  # CAS 2.3
  # Simply destroys the tgt cookie
  get '/logout' do
    @messages << "The application you just logged out from has provided a link it would like you to follow. Please click here to access #{CGI.unescape(params[:url])}" if params[:url]
    @messages << "You've successfully logged out!" if @messages.empty?

    response.delete_cookie 'tgt'

    erb 'login.html'.to_sym
  end

  # CAS 2.4
  get '/validate' do
    requires_params({:service => "Service param", :ticket => "Ticket param"})

    halt 401, "no<LF><LF>" if ((not @errors.empty?) || @ticket.nil? || @ticket.consumed?)
    halt 200, "yes<LF>#{@ticket.permanent_id}<LF>"
  end

  # CAS 2.5 and CAS 2.6

  ["/serviceValidate", "/proxyValidate"].each do |path|

    get path do
      codes = {:INVALID_REQUEST => 400,
               :INVALID_TICKET  => 401,
               :INVALID_SERVICE => 401}

      error, message, service_ticket = CasFuji::Models::ServiceTicket.validate_ticket(@service, params[:ticket])

      if error
        @errors = [codes[error], error, message]
        halt(@errors.first, builder('service_validate_failure.xml'.to_sym))
      end

      # The user has successfully authenticated, save a TGT for their next visit
      session['tgt'] = CasFuji::Models::TicketGrantingTicket.generate(@client_hostname, service_ticket.authenticated, service_ticket.permanent_id).name

      @extra_attributes = self.class.extra_attributes_for(service_ticket.authenticator, service_ticket.permanent_id)
      halt(200, builder('service_validate_success.xml'.to_sym))
    end
  end

  # CAS 2.7
  get '/proxy' do
    # TODO: Implement
    raise CasFuji::UnimplementedError
  end

  ## ============================================================
  ## 
  ## Helpers
  ## 
  ## ============================================================
  class << self
    def append_ticket_to_url(url, service_ticket)
      uri = ::Addressable::URI.parse(url)
      uri.query_values = {"ticket" => service_ticket}
      uri.to_s
    end

    def authenticate_user!(username, password)
      params = {
        :username => username,
        :password => password,
      }

      CasFuji.config[:authenticators].each do |authenticator|
        permanent_id = authenticator[:class].constantize.validate(params)
        return [authenticator[:class], permanent_id] if permanent_id
      end

      return nil
    end

    # TODO store the name of the authenticator in the ServiceTicket table
    # Another way is to check if it can be stored in a session/cookie
    # This is just a temporary workaround for now.
    def extra_attributes_for(authenticator, permanent_id)
      return ("::" + authenticator).constantize.extra_attributes_for(permanent_id)
    end

    def valid_ticket?(ticket)
      # Will return false if ticket is nil or has been consumed
      ticket.try(:consumed?) == false
    end
  end

  private

  def requires_params(params)
    params.each_pair do |param_symbol, human_name|
      @errors << "#{human_name} is required" unless self.instance_variable_get("@#{param_symbol}")
    end
  end

  def current_user
    session[:user] if not params[:renew]
    
    if @tgt = CasFuji::Models::TicketGrantingTicket.validate_ticket(session['tgt'])
      return extra_attributes_for(@tgt.authenticator, tgt.permanent_id)
    end
  end

  # Initialize and massage the variables ahead of time
  def set_request_variables!
    @client_hostname = @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_HOST'] || @env['REMOTE_ADDR']


    @ticket   = ::CasFuji::Models::ServiceTicket.find_by_name(params[:ticket])
    @service  = params[:service]
    @pgt_url  = params[:pgt_url]
    @renew    = params[:renew]
    @username = params[:username]
    @password = params[:password]
    @lt       = params[:lt]

    @errors   = []
    @messages = []
  end

  def flash
  signed_message = request.cookies['_bushido_session']
  
    if signed_message.present?
      secret = Bushido::Application.config.secret_token
      verifier = ActiveSupport::MessageVerifier.new(secret)
      session = verifier.verify(signed_message)

      flash = session.delete('flash')
      
      signed_message = verifier.generate(session)
      response.set_cookie('_bushido_session', :value => signed_message, :path => '/')
      return flash
    end
  end
end
