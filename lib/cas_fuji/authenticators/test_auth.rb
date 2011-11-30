module CasFuji
  module Authenticators
    class TestAuth < Base

      def self.validate(username, password, params=nil)
        return "test_permanent_id" if(username == "test_username" && password == "test_password")
        return false
      end

    end
  end
end
