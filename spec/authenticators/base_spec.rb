require "spec_helper"

describe CasFuji::Authenticators::Base do

  describe "validate" do
    it "should raise CasFuji::Exception" do
      expect {
        ::CasFuji::Authenticators::Base.validate({})
      }.to raise_error(CasFuji::Exception)
    end
  end

  describe "extra_attributes_for" do
    it "should raise CasFuji::Exception" do
      expect {
        ::CasFuji::Authenticators::Base.extra_attributes_for({})
      }.to raise_error(CasFuji::Exception)
    end
  end
  
end
