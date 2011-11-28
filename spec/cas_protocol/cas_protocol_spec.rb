require File.expand_path("#{Dir.pwd}/spec/spec_helper")

require 'cgi'
require 'ap'

describe 'CAS protocol examples' do
  include Rack::Test::Methods

  def app
    CasFuji::App
  end

  def response
    last_response
  end

  it 'should not prompt for username/password' do
    get '/login?service=http%3A%2F%2Fwww.service.com&gateway=true'
    last_response.status.should == 302
  end

  it 'should always prompt for username/password' do
    get '/login?service=http%3A%2F%2Fwww.service.com&renew=true'
    last_response.body.should include("please login")
  end
end
