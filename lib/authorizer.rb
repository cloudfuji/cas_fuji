module CasFuji
  class Authorizer
    
    # By default the CAS protocol doesn't do authorization, so we
    # simply return true by default. But this callback allows for
    # authorization on top of authentication.
    def self.authorized?(permanent_id, service_target)
      true
    end

  end
end
