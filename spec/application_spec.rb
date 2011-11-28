require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CasFuji do
  include Rack::Test::Methods

  def app
    CasFuji
  end

  it 'should run a simple test' do
    app.should_not be_nil
  end
end
