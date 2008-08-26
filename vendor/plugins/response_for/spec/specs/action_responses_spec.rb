require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe 'class method #action_responses' do
  before do
    @parent = Class.new(ActionController::Base)
    @action_response = mock('lambda')
    @parent_action_response = [@action_response]
    @parent.send(:action_responses)[:action] = @parent_action_response
    @child = Class.new(@parent)
    @grandchild = Class.new(@child)
  end
  
  it "@child.action_responses[:action] should be copy of parent's action response for :action" do
    @child.send(:action_responses)[:action].should == @parent_action_response
  end 

  it "@grandchild.action_responses[:action] should be copy of @child.action_responses[:action]" do
    @grandchild.send(:action_responses)[:action].should == @child.send(:action_responses)[:action]
  end
  
  it "@child.action_responses[:action] not be same object as parent's action response for :action" do
    @child.send(:action_responses)[:action].should_not equal(@parent_action_response)
  end 

  it "@grandchild.action_responses[:action] not be same object as @child.action_responses[:action]" do
    @grandchild.send(:action_responses)[:action].should_not equal(@child.send(:action_responses)[:action])
  end
  
  it "adding to @grandchild.action_responses[:action] should not change parents" do
    a_lambda = lambda {}
    @grandchild.send(:action_responses)[:action] << a_lambda
    @grandchild.send(:action_responses)[:action].should == [@action_response, a_lambda]
    @child.send(:action_responses)[:action].should == [@action_response]
    @parent.send(:action_responses)[:action].should == [@action_response]
  end
end