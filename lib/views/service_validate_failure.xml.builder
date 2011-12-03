xml.cas(:serviceResponse, :xmlns => 'http://www.yale.edu/tp/cas') do |service_response|
  service_response.cas(:authenticationFailure, {:code => @errors[1]}, @errors.last)
end
