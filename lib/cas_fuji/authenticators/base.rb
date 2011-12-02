module CasFuji
  module Authenticators
    class Base

      def self.extra_attributes_for(permanent_id)
        raise ::CasFuji::Exception.new "This method has to be implemented within every CasFuji authenticator"
      end
      
      def self.validate(params)
        raise ::CasFuji::Exception.new "This method has to be implemented within every CasFuji authenticator"
      end

    end
  end
end
