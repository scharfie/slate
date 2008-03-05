require File.dirname(__FILE__) + '/../spec_helper'

begin
  Object.send :remove_const, :ApplicationTestController
  Object.send :remove_const, :ApplicationRCTestController
rescue
end

class ApplicationTestController < ApplicationController
  def some_action
    render :text => 'ApplicationTest#some_action'
  end
end

class ApplicationRCTestController < ApplicationController
  def some_action
    render :text => 'ApplicationRCTest#some_action'
  end
  
  def load_enclosing_resources
    @space = Space.find(152)
  end
end

describe ApplicationTestController do
  before(:each) do
    request.host = 'slate.local.host'
    controller.request = request
    @user = mock(User)
  end
 
  it "should have a nil active space for non-RC controllers" do
    controller.should_receive(:capture_user).and_return(@user)
    get 'some_action'
    Space.active.should be_nil
  end
end

describe ApplicationRCTestController do
  before(:each) do
    request.host = 'slate.local.host'
    @user = mock(User)
  end
   
  it "should set the active space for RC controllers (simulated)" do
    controller.should_receive(:capture_user).and_return(@user)    
    Space.should_receive(:find).with(152).and_return(@space)
    
    get 'some_action'
    Space.active.should == @space
  end
end