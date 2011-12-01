# TODO: Prefix all urls with mounting point
class CasFuji::App < Sinatra::Base

  set :database, "postgres://vagrant:vagrant@localhost/bushido_development"
  #set :views, Proc.new { File.join("#{Rails.root}", "lib/cas_fuji/lib/cas_fuji/views") }

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
    requires_params({:username => "Username", :password => "Password", :lt => "Login ticket"})

    # mark the login ticket as consumed if it's a valid login ticket
    ::CasFuji::Models::LoginTicket.consume(@lt) if @lt

    permanent_id = self.class.authenticate_user!(params[:username], params[:password]) if @errors.empty?
    @errors << "Invalid username and password" if permanent_id.nil?

    halt(401, erb('login.html'.to_sym)) if not @errors.empty?

    # TODO refactor this. LoginTicket is being generated twice in this action
    if not @errors.empty?
      @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
      halt(401, erb('login.html'.to_sym))
    end

    if @service and @errors.empty?
      st = ::CasFuji::Models::ServiceTicket.generate(@service, permanent_id, @client_hostname)
      halt(200, erb('redirect_warn.html'.to_sym)) if params[:warn]
      redirect self.class.append_ticket_to_url(st.service_url, st.name)
    end

    @messages << "Successfully logged in"

    # TODO check for old ticket and use that instead
    @login_ticket_name = ::CasFuji::Models::LoginTicket.generate(@client_hostname).name
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

  # CAS 2.5 and CAS 2.6

  ["/serviceValidate", "/proxyValidate"].each do |path|

    get path do
      # Case-1 service isn't passed in the param
      @errors = [400, "INVALID_REQUEST", "Service is required"] if not @service

      # Case-2 ticket isn't passed
      @errors = [400, "INVALID_REQUEST", "Ticket is required"]  if @raw_ticket.nil?

      # Case-3 If ticket isn't found or has been consumed
      @errors = [401, "INVALID_TICKET",  "Invalid ticket"]      if @errors.empty? and not self.class.valid_ticket?(@ticket)

      # Case-4 If service encoding isn't valid or if ticket doesnt correspond to service
      @errors = [401, "INVALID_SERVICE", "Invalid service"]     if @errors.empty? and (not @ticket.service_valid?(@service))

      if @errors.empty?
        @extra_attributes = self.class.extra_attributes_for @ticket.permanent_id
        halt(200, builder('service_validate_success.xml'.to_sym))
      end

      halt(@errors.first, builder('service_validate_failure.xml'.to_sym))
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
        permanent_id = authenticator["class"].constantize.validate(params)
        return permanent_id if permanent_id
      end

      return nil
    end

    # TODO store the name of the authenticator in the ServiceTicket table
    # Another way is to check if it can be stored in a session/cookie
    # This is just a temporary workaround for now.
    def extra_attributes_for(permanent_id)
      ::CasFuji::Authenticators::TestAuth.extra_attributes_for(permanent_id)
      # ::BushidoFuji.extra_attributes_for(permanent_id)
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
    # TODO: Implement how to retrieve the current user based off of cookie/ticket/etc.
    session[:user] if not params[:renew]
  end

  # Initialize and massage the variables ahead of time
  def set_request_variables!
    current_user

    @raw_ticket             = params[:ticket]
    @client_hostname = @env['HTTP_X_FORWARDED_FOR'] || @env['REMOTE_HOST'] || @env['REMOTE_ADDR']
    @service                = params[:service]

    @ticket  = ::CasFuji::Models::ServiceTicket.find_by_name(@raw_ticket)

    @pgt_url = params[:pgt_url]
    @renew   = params[:renew]

    @username = params[:username]
    @password = params[:password]
    @lt = params[:lt]

    @errors   = []
    @messages = []
  end
end
