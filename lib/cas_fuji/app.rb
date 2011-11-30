# TODO: Prefix all urls with mounting point
class CasFuji::App < Sinatra::Base
  
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
    redirect append_ticket_to_url(@service, "valid")            if params[:gateway] and current_user and @service
    redirect @service                                           if params[:gateway]
    @messages << "you're already logged in as #{current_user}!" if current_user
    @login_ticket_name = LoginTicket.generate(@client_hostname).name

    erb 'login.html'.to_sym
  end

  # CAS 2.2
  post '/login' do
    requires_params({:username => "Username", :password => "Password", :lt => "Login ticket"})

    # mark the login ticket as consumed if it's a valid login ticket
    LoginTicket.consume(@lt) if @lt
    
    permanent_id = authenticate_user!(params[:username], params[:password]) if @errors.empty?

    halt(401, erb('login.html'.to_sym)) if not @errors.empty?

    if @service and @errors.empty?
      st = ServiceTicket.generate(@service, permanent_id, @client_hostname)
      halt(200, erb('redirect_warn.html'.to_sym)) if params[:warn]
      redirect append_ticket_to_url(@service, st.name)
    end

    @messages << "Successfully logged in"

    # TODO check for old ticket and use that instead
    @login_ticket_name = LoginTicket.generate(@client_hostname).name
    halt(200, erb('login.html'.to_sym))
  end

  # CAS 2.3
  # Simply destroys the tgt cookie
  get '/logout' do
    @messages << "The application you just logged out of has provided a link it would like you to follow. Please click here to access #{CGI.unescape(params[:url])}" if params[:url]

    erb 'logout.html'.to_sym
  end

  # CAS 2.4
  get '/validate' do
    requires_params({:service => "Service param", :ticket => "Ticket param"})

    halt 401, "no<LF><LF>" if ((not @errors.empty?) || @ticket.nil? || @ticket.consumed?)
    halt 200, "yes<LF>#{@ticket.permanent_id}<LF>"
  end

  # CAS 2.5
  get '/serviceValidate' do
    # Case-1 service isn't passed in the param
    @errors = [400, "INVALID_REQUEST", "Service is required"] if not @service

    # Case-2 ticket isn't passed
    @errors = [400, "INVALID_REQUEST", "Ticket is required"]  if @raw_ticket.nil?

    # Case-3 If ticket isn't found or has been consumed
    @errors = [401, "INVALID_TICKET",  "Invalid ticket"]      if @errors.empty? && (!valid_ticket?)

    # Case-4 If service encoding isn't valid or if ticket doesnt correspond to service
    @errors = [401, "INVALID_SERVICE", "Invalid service"]     if @errors.empty? && (invalid_service_encoding? || ticket_with_invalid_service?)

    halt(200, builder('service_validate_success.xml'.to_sym)) if @errors.empty?
    halt(@errors.first, builder('service_validate_failure.xml'.to_sym))
  end

  # CAS 2.6
  get '/proxyValidate' do
    # TODO: Implement
    raise CasFuji::UnimplementedError
  end

  # CAS 2.7
  get '/proxy' do
    # TODO: Implement
    raise CasFuji::UnimplementedError
  end

  private

  ## ============================================================
  ## 
  ## Helpers
  ## 
  ## ============================================================
  def requires_params(params)
    params.each_pair do |param_symbol, human_name|
      @errors << "#{human_name} is required" unless self.instance_variable_get("@#{param_symbol}")
    end
  end

  def current_user
    # TODO: Implement how to retrieve the current user based off of cookie/ticket/etc.
    session[:user] if not params[:renew]
  end

  def append_ticket_to_url(url, service_ticket)
    uri = ::Addressable::URI.parse(url)
    uri.query_values = {"ticket" => service_ticket}
    uri.to_s
  end

  def authenticate_user!(username, password)
    CasFuji.config[:authenticators].each do |authenticator|
      permanent_id = authenticator["class"].constantize.validate(username, password)
      return permanent_id if permanent_id
    end
    @errors << "Invalid username and password"
  end

  def invalid_service_encoding?
    @service_encoding_valid == false
  end

  def existing_ticket?
    !@raw_ticket.nil? && !@ticket.nil?
  end

  def valid_ticket?
    existing_ticket? && @ticket.not_consumed?
  end
  
  def ticket_with_invalid_service?
    puts "TICKET SERVICE #{@service}"
    !(valid_ticket? && @ticket.service_valid?(@service))
  end
  
  # Initialize and massage the variables ahead of time
  def set_request_variables!
    current_user
    
    raw_service             = params[:service]
    @raw_ticket             = params[:ticket]

    @client_hostname = @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_HOST'] || @env['REMOTE_ADDR']
    @service                = CGI.unescape(raw_service) if raw_service
    escaped_service         = CGI.escape(@service)      if @service
    @service_encoding_valid = (escaped_service == raw_service)

    @ticket  = ServiceTicket.find_by_name(@raw_ticket)
    @pgt_url = params[:pgt_url]
    @renew   = params[:renew]

    @username = params[:username]
    @password = params[:password]
    @lt = params[:lt]

    @errors   = []
    @messages = []
    
    @errors << "Sorry, that doesn't look like a valid service param" if @service and not @service_encoding_valid
  end
end
