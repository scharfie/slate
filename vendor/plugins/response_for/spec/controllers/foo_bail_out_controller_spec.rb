require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe FooBailOutController do
  it "get :foo, :bail_out => true should redirect" do
    get :foo, :bail_out => true
    response.should redirect_to("http://test.host/redirected")
  end
end