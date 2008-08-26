require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe XmlOnlyFooController do
  it "get :foo should render xml: foo" do
    get :foo
    response.should render_template(:foo)
    response.content_type.should == 'application/xml'
  end
  
  it "get :bar should render xml: bar" do
    get :bar
    response.should render_template(:bar)
    response.content_type.should == 'application/xml'
  end
  
  it "get :foo should assign @foo" do
    get :foo
    assigns[:foo].should == 'Foo'
  end
    
  it "get :foo, :format => 'html' should not render foo" do
    get :foo, :format => 'html'
    lambda{ response.should render_template(:foo) }.should raise_error
  end
  
  it "get :foo, :format => 'xml' should render foo" do
    get :foo, :format => 'xml'
    response.should render_template(:foo)
    response.content_type.should == 'application/xml'
  end
end