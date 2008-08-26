require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe FooController do
  it "get :foo should render text/html: foo" do
    get :foo
    response.should render_template(:foo)
    response.content_type.should == 'text/html'
  end
  
  it "get :foo should assign @foo" do
    get :foo
    assigns[:foo].should == 'Foo'
  end
    
  it "get :foo, :format => 'html' should render foo" do
    get :foo, :format => 'html'
    response.should render_template(:foo)
  end
  
  it "get :foo, :format => 'xml' should not render foo" do
    get :foo, :format => 'xml'
    lambda{ response.should render_template(:foo) }.should raise_error
  end
end