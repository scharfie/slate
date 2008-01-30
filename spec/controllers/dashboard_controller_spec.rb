require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardController do
  before(:each) do
    @user = mock(User)
    @space = mock(Space)
    
    request.host = 'slate.local.host'
  end
  
  it "should render space dashboard when on GET to /spaces/1/dashboard" do
    Space.should_receive(:find).with('1').and_return(@space)
    User.should_receive(:find_by_id).with(77).and_return(@user)
    
    session[:user_id] = 77
    
    get 'show', :space_id => 1
    response.should_not be_redirect
    response.should be_success
    response.should render_template('space')
  end
  
  it "should render admin dashboard when super user on GET to /dashboard" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    User.should_receive(:active).and_return(@user)
    @user.should_receive(:super_user?).and_return(true)
    
    session[:user_id] = 77
    
    get 'show'
    response.should_not be_redirect
    response.should be_success
    response.should render_template('admin')
  end
  
  it "should render user dashboard when normal user on GET to /dashboard" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    User.should_receive(:active).and_return(@user)
    @user.should_receive(:super_user?).and_return(false)
    
    session[:user_id] = 77
    
    get 'show'
    response.should_not be_redirect
    response.should be_success
    response.should render_template('user')
  end
end

describe DashboardController, "with user logged in" do
  before(:each) do
    @verbs = %w(get post put delete)
    @user = mock(User)
    User.should_receive(:find_by_id).with(77).
      exactly(@verbs.length).and_return(@user)
    session[:user_id] = 77
    
    request.host = 'slate.local.host'
  end
  
  def any_verb_on_action_should_redirect_to_show(action)
    @verbs.each do |verb|
      send verb, action
      response.should be_redirect
      response.should redirect_to(dashboard_url)
    end
  end
  
  it "should redirect to show on ANY to /new" do
    any_verb_on_action_should_redirect_to_show :new
  end
  
  it "should redirect to show on ANY to /edit" do
    any_verb_on_action_should_redirect_to_show :edit
  end
end