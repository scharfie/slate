require File.dirname(__FILE__) + '/../spec_helper'

describe SpacesController do
  before(:each) do
    request.host = 'slate.local.host'
  end

  it "should redirect to space dashboard on GET to /show" do
    controller.should_receive(:capture_user).and_return(true)
    get 'show', :id => 77
    response.should redirect_to(space_dashboard_url(77))
  end
  
  it "should scope the retrieval of spaces for current user on GET to /index" do
    @user = mock(User)
    @space = mock(Space)
    @user.should_receive(:super_user?).and_return(false)
    @user.should_receive(:spaces).and_return(Space)
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:find).and_return([@space])
    controller.should_receive(:capture_user).and_return(true)
    
    get 'index'
    response.should render_template(:index)
    assigns[:spaces].should == [@space]
  end
  
  it "should assign active Space on GET to /edit" do
    @user = mock(User)
    @space = mock(Space)
    @user.should_receive(:super_user?).and_return(false)
    @user.should_receive(:spaces).and_return(Space)
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:find).with('143').and_return(@space)
    controller.should_receive(:capture_user).and_return(true)
    
    get 'edit', :id => 143
    Space.active.should == @space
  end
  
  it "should build new Space for super user on GET to /new" do
    @user = mock(User)
    @space = mock(Space)
    @user.should_receive(:super_user?).at_least(1).and_return(true)
    User.should_receive(:active).at_least(1).and_return(@user)
    controller.should_receive(:capture_user).and_return(true)
    
    get 'new'
    response.should render_template(:new)
    assigns['_space'].should be_a_kind_of(Space)
  end  
  
  it "should redirect to space dashboard on POST to /choose" do
    controller.should_receive(:capture_user).and_return(true)
    
    post 'choose', :space_id => 33
    response.should redirect_to(space_dashboard_url(33))
  end
end