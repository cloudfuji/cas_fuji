require 'spec_helper'

describe "CasProtocol 2.1" do

  describe "login page" do
    it "should value default value for login ticket" do
      visit "/login"
      find_field("lt").value.should =~ /LT-.*/
    end
  end

end
