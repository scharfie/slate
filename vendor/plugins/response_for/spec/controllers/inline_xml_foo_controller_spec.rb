require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe InlineXmlFooController do
  before do
    controller.stub!(:xml_call).and_return('XML')
  end
  
  it "get :foo should assign @foo" do
    get :foo
    assigns[:foo].should == 'Foo'
  end
    
  it "get :foo, :format => 'html' should render 'foo'" do
    get :foo, :format => 'html'
    response.should render_template(:foo)
  end
  
  it "get :foo, :format => 'xml' should call xml_call with 'foo" do
    controller.should_receive(:xml_call).with('foo')
    get :foo, :format => 'xml'
  end
  
  it "get :foo, :format => 'xml' should have response.body of 'XML'" do
    get :foo, :format => 'xml'
    response.body.should == 'XML'
  end
end