class CasFuji::App < Sinatra::Base

  ## ============================================================
  ## 
  ## Basic setup
  ##
  ## Set all the configuration and error handlers
  ##
  ## ============================================================

  set :views, CasFuji.config[:templates][:path]

  CasFuji.config[:sinatra_settings].each_pair do |key, value|
    set key, value
  end

  not_found do
    File.read(CasFuji.config[:templates][:error_404_html])
  end

  error do
    File.read(CasFuji.config[:templates][:error_500_html])
  end


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
    redirect_with_ticket(@service, @tgt.authenticator, @tgt.permanent_id, @client_hostname, @tgt.id) if current_user && @service && authorize_user! && params[:warn].nil?
    redirect @service if params[:gateway] and @service
    @messages << "You're already logged in!" if current_user

    @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name

    erb 'login.html'.to_sym
  end

  get '/invite' do
    requires_params({'invitation_token' => "Invitation Token"})

    authenticator, permanent_id = self.class.authenticate_user!(params[:username], params[:password], params) if @errors.empty?
    @errors << "Invalid invitation token" if permanent_id.nil?

    if @errors.empty?
      # The user has successfully authenticated, save a TGT for their next visit
      ticket_granting_ticket = CasFuji::Models::TicketGrantingTicket.generate(@client_hostname, authenticator, permanent_id)
      response.set_cookie('tgt', {:value => ticket_granting_ticket.name, :path => CasFuji.config[:rack][:mount_url], :expires => 15.days.from_now})

      # Update @tgt
      set_tgt!(ticket_granting_ticket.name)
      
      if @service && !authorize_user!
        user = User.find_by_email(@username)
        notify_activity("User unauthorized to access app", "#{user.email} signed in, but unauthorized to access #{@service}")

        halt(401, erb('unauthorized.html'.to_sym))
      end
    end

    # TODO refactor this. LoginTicket is being generated twice in this action
    if not @errors.empty?
      @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
      notify_activity("User failed to login", "Invitation token: #{@invitation_token}: #{@errors.inspect}")

      halt(401, erb('login.html'.to_sym))
    end

    if @service and @errors.empty?
      user = User.find_by_email(@username)
      notify_activity("User signed in (invite token)", "#{user.email} signed in for the #{user.sign_in_count.ordinalize} time, accessing #{@service}")

      @destination = url_with_ticket(@service, authenticator, permanent_id, @client_hostname, ticket_granting_ticket.id)
      @destination += "&redirect=#{params[:redirect]}" if params[:redirect]
      halt(200, erb('invite.html'.to_sym))
    end

    @messages << "Successfully logged in"
    @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
    halt(200, erb('login.html'.to_sym))
  end

  # CAS 2.2
  post '/login' do
    requires_params({:username => "Username", :password => "Password", :lt => "Login ticket"})
    
    # Mark the login ticket as consumed if it's a valid login ticket
    ::CasFuji::Models::LoginTicket.consume(@lt) if @lt

    authenticator, permanent_id = self.class.authenticate_user!(params[:username], params[:password], params) if @errors.empty?
    @errors << "Invalid username and password" if permanent_id.nil?

    halt(401, erb('login.html'.to_sym)) if not @errors.empty?

    ticket_granting_ticket = nil
    if @errors.empty?
      # The user has successfully authenticated, save a TGT for their next visit
      ticket_granting_ticket = CasFuji::Models::TicketGrantingTicket.generate(@client_hostname, authenticator, permanent_id)
      response.set_cookie('tgt', {:value => ticket_granting_ticket.name, :path => CasFuji.config[:rack][:mount_url], :expires => 15.days.from_now})

      # Update @tgt
      set_tgt!(ticket_granting_ticket.name)

      if @service && !authorize_user!
        halt(401, erb('unauthorized.html'.to_sym))
      end
    end


    # TODO refactor this. LoginTicket is being generated twice in this action
    if not @errors.empty?
      @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
      halt(401, erb('login.html'.to_sym))
    end

    if @service and @errors.empty?
      user = User.find_by_email(@username)
      notify_activity("User signed in (login)", "#{user.email} signed in for the #{user.sign_in_count.ordinalize} time to access #{@service}")

      halt(200, erb('redirect_warn.html'.to_sym)) if params[:warn]
      redirect_with_ticket(@service, authenticator, permanent_id, @client_hostname, ticket_granting_ticket.id)
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

    ticket_granting_ticket = ::CasFuji::Models::TicketGrantingTicket.find_by_name(request.cookies['tgt'])
    Resque.enqueue(LogoutNotifier, {:command=>"logout_all", :ticket_granting_ticket_id => ticket_granting_ticket.id}) if ticket_granting_ticket

    # Rack has a hard time deleting out cookie right, so we manually
    # remove the cookie value and expire the cookie here
    response.set_cookie('tgt', {:value => '', :path => CasFuji.config[:rack][:mount_url], :expires => Time.at(0)})

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
      
      service_ticket.consume!
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

    def authenticate_user!(username, password, params={})
      _params = {
        :username => username,
        :password => password,
      }

      params.merge!(_params)

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

  def url_with_ticket(service, authenticator, permanent_id, client_hostname, ticket_granting_ticket_id)
    url = self.class.append_ticket_to_url(
      service,
      ::CasFuji::Models::ServiceTicket.generate(
        authenticator,
        service,
        permanent_id,
        client_hostname,
        ticket_granting_ticket_id).name)
  end

  def redirect_with_ticket(service, authenticator, permanent_id, client_hostname, ticket_granting_ticket_id)
    service = CasFuji.config[:cas][:default_service_url] if service.empty?
    service = CGI.unescape(service)
    url     = url_with_ticket(service, authenticator, permanent_id, client_hostname, ticket_granting_ticket_id)
    redirect url
  end

  def authorize_user!
    authorized = CasFuji.config[:authorizer][:class].constantize.authorized?(@tgt.permanent_id, @service)

    @errors << "You are not authorized to access this app" unless authorized and @tgt
    return authorized
  end

  def requires_params(params)
    params.each_pair do |param_symbol, human_name|
      @errors << "#{human_name} is required" unless self.instance_variable_get("@#{param_symbol}")
    end
  end

  def current_user
    return nil if params[:renew] or @tgt.nil?

    self.class.extra_attributes_for(@tgt.authenticator, @tgt.permanent_id) if @tgt
  end

  def set_tgt!(ticket_name=nil)
    # Set the cookie based off of @tgt or fall through to the tgt
    # field in the incoming cookie (if it's there)
    ticket_name ||= request.cookies['tgt']

    @tgt = ::CasFuji::Models::TicketGrantingTicket.validate_ticket(ticket_name) if ticket_name
  end

  def notify_activity(title, body)
      begin
        # hardcoded for production settings right now
        notification          = Notification.new
        notification.user_id  = 1
        notification.app_id   = 26250
        notification.title    = title
        notification.body     = body
        notification.category = "User Activity"
        notification.save(:validate => false)

        puts notification.inspect
      rescue => e
        puts "Couldn't save notification: #{e.inspect}"
      end
  end

  # Initialize and massage the variables ahead of time
  def set_request_variables!
    @client_hostname = @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_HOST'] || @env['REMOTE_ADDR']

    set_tgt!

    @ticket           = ::CasFuji::Models::ServiceTicket.find_by_name(params[:ticket])
    @invitation_token = params[:invitation_token]
    @service          = params[:service]
    @pgt_url          = params[:pgt_url]
    @renew            = params[:renew]
    @username         = params[:username]
    @password         = params[:password]
    @lt               = params[:lt]

    @flash            = flash || {}

    @errors           = []
    @messages         = @flash.values
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
