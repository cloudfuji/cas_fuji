module CasFuji
  module Authenticators
    class Base

      def self.validate(username, password)
        CasFuji::Error "This method has to be implemented within every CasFuji authenticator"
      end

    end
  end
end
