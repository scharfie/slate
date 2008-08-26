require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe BackToFooController do
  it "get :foo, :format => 'xml' should not render foo" do
    get :foo, :format => 'xml'
    lambda{ response.should render_template(:foo) }.should raise_error
  end
end