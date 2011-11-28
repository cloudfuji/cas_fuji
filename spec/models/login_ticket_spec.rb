require 'spec_helper'

describe LoginTicket do

  describe "generate" do
    it "should generate a new LoginTicket with name" do
      LoginTicket.generate.name.should =~ /LT-.*/
    end
  end

end
