module CasFuji
  module Authenticators
    class TestAuth < Base

      def self.extra_attributes_for(permanent_id)
        {
          :first_name => "John",
          :last_name  => "Doe",
          :locale     => "en",
          :email      => "johndoe@example.com"
        }
      end
      
      def self.validate(params)
        return "test_permanent_id" if(params[:username] == "test_username" && params[:password] == "test_password")
        return false
      end

    end
  end
end
