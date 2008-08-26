require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe XmlFooController do
  it "get :foo should render foo" do
    get :foo
    response.should render_template(:foo)
  end
  
  it "get :foo should assign @foo" do
    get :foo
    assigns[:foo].should == 'Foo'
  end
  
  it "get :foo, :format => 'html' should render foo" do
    get :foo, :format => 'html'
    response.should render_template(:foo)
  end
  
  it "get :foo, :format => 'xml' should render foo" do
    get :foo, :format => 'xml'
    response.should render_template(:foo)
    response.content_type.should == 'application/xml'
  end
  
  it "get :bar, :format => 'xml' should render bar" do
    get :bar, :format => 'xml'
    response.should render_template(:bar)
    response.content_type.should == 'application/xml'
  end
end