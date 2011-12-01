module CasFuji
  module Authenticators
    class Base

      def self.extra_attributes_for(permanent_id)
        CasFuji::Error "This method has to be implemented within every CasFuji authenticator"
      end
      
      def self.validate(params)
        CasFuji::Error "This method has to be implemented within every CasFuji authenticator"
      end

    end
  end
end
