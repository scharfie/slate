require File.dirname(__FILE__) + '/../spec_helper'

begin
  Object.send :remove_const, :ApplicationTestController
  Object.send :remove_const, :ApplicationRCTestController
rescue
end

class ApplicationTestController < ApplicationController
  before_filter :ensure_super_user!, :only => :super_user_action
  
  def super_user_action
    render :text => 'ApplicationController#super_user_action'
  end
  
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
    @user = mock(User)
  end
  
  it "should redirect to login when not logged in on GET to /some_action" do
    User.should_receive(:find_by_id).with(nil).and_return(nil)
    session[:user_id] = nil

    get 'some_action'
    response.should be_redirect
    response.should redirect_to(login_url)
    session[:redirect_to].should == 'http://slate.local.host/application_test/some_action'
  end
  
  it "should render test when logged in on GET to /some_action" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    session[:user_id] = 77
    
    get 'some_action'
    response.should have_text('ApplicationTest#some_action')
    User.active.should == @user
  end
  
  it "should redirect to login when not super-user on GET to /super_user_action" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    session[:user_id] = 77
    
    @user.should_receive(:super_user?).and_return(false)
    
    get 'super_user_action'
    response.should redirect_to(login_url)
    flash[:error].should == 'Super user is required to perform this task.'
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