require "spec_helper"

describe ::CasFuji::Authenticators::TestAuth do

  describe "validate should accept credentials in a hash and" do
    
    it "should return ido_id of the user if valid" do
      params = {:username => "test_username", :password => "test_password"}

      ::CasFuji::Authenticators::TestAuth.validate(params).should == "test_permanent_id"
    end

    it "should return false if the password is wrong" do
      params = {:username => "test_username", :password => "invalid_password"}

      ::CasFuji::Authenticators::TestAuth.validate(params).should == false
    end

    it "should return false if the username is wrong" do
      params = {:username => "invalid_user", :password => "invalid_password"}

      ::CasFuji::Authenticators::TestAuth.validate(params).should == false
    end
  end

  
  describe "extra_attributes_for" do
    it "should return the extra attributes of the user when ido_id is passed" do
      expected_hash = {
        :first_name => "John",
        :last_name  => "Doe",
        :locale     => "en",
        :email      => "johndoe@example.com"
      }

      ::CasFuji::Authenticators::TestAuth.extra_attributes_for("test_permanent_id").should == expected_hash
    end
  end

end
