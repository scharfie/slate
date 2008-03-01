require File.dirname(__FILE__) + '/../spec_helper'

begin
  Object.send :remove_const, :AuthenticationTestController
  Object.send :remove_const, :AuthenticationRCTestController
rescue
end

class AuthenticationTestController < ActionController::Base
  include Slate::Authentication
  before_filter :capture_user!
  before_filter :ensure_super_user!, :only => :super_user_action
  
  def super_user_action
    render :text => 'AuthenticationController#super_user_action'
  end
  
  def some_action
    render :text => 'AuthenticationTest#some_action'
  end
end

describe AuthenticationTestController do
  before(:each) do
    request.host = 'slate.local.host'
    controller.request = request
    @user = mock(User)
  end
  
  it "should return true for slate? for slate.local.host" do
    controller.slate?.should == true
  end
  
  it "should return false for slate? for example.local.host" do
    request.host = 'example.local.host'
    controller.slate?.should == false
  end
  
  it "should return true for super_user? when logged in as super user" do
    User.should_receive(:active).twice.and_return(@user = mock(User))
    @user.should_receive(:super_user?).and_return(true)
    controller.super_user?.should == true
  end

  it "should return false for super_user? when logged but not super user" do
    User.should_receive(:active).twice.and_return(@user = mock(User))
    @user.should_receive(:super_user?).and_return(false)
    controller.super_user?.should == false
  end
  
  it "should return false for super_user? when not logged in" do
    User.should_receive(:active).and_return(nil)
    controller.super_user?.should == false
  end
  
  it "should redirect to login when not logged in on GET to /some_action" do
    User.should_receive(:find_by_id).with(nil).and_return(nil)
    session[:user_id] = nil

    get 'some_action'
    response.should be_redirect
    response.should redirect_to(login_url)
    session[:redirect_to].should == 'http://slate.local.host/authentication_test/some_action'
  end
  
  it "should render test when logged in on GET to /some_action" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    session[:user_id] = 77
    
    get 'some_action'
    response.should have_text('AuthenticationTest#some_action')
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
  
  it "should login from cookie" do
    User.should_receive(:find_by_remember_token).with('abcdef').and_return(@user)
    controller.stub!(:cookies).and_return(:auth_token => 'abcdef')
    controller.should_receive(:save_login_cookie)
    controller.login_from_cookie
    controller.current_user.should == @user
  end
  
  it "should save login cookie" do
    cookie = { :value => 'abcdef', :expires => Time.now }
    @user.should_receive(:remember_me!)
    @user.should_receive(:remember_token_as_cookie).and_return(cookie)
    controller.current_user = @user
    controller.stub!(:cookies).and_return({})
    controller.cookies[:auth_token].should == nil
    controller.save_login_cookie
    controller.cookies[:auth_token].should == cookie
  end
end

describe AuthenticationTestController, 'with user logged in' do
  before(:each) do
    @user = mock(User)
    User.active = @user
  end
  
  it "should return true for logged_in?" do
    controller.should be_logged_in
    controller.current_user.should == @user
  end
  
  it "should logout current user" do
    controller.stub!(:cookies).and_return(:auth_token => 'abcdef')
    @user.should_receive(:forget_me!)
    
    controller.logout_current_user
    controller.should_not be_logged_in
    cookies.should_not have_key(:auth_token)
  end
end