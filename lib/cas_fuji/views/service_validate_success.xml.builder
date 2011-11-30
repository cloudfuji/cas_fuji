xml.cas(:serviceResponse, :xmlns => 'http://www.yale.edu/tp/cas') do |service_response|
  service_response.cas(:authenticationSuccess) do |authentication_success|
    authentication_success.cas(:user, @ticket.permanent_id)
    authentication_success.cas(:proxyGrantingTicket, @proxy_granting_ticket) if @proxy_granting_ticket
  end
end
