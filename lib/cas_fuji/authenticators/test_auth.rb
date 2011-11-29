module CasFuji
  module Authenticators
    class TestAuth < Base

      def self.validate(username, password)
        return true if username == "test_username" && password == "test_password"
        return false
      end

    end
  end
end
