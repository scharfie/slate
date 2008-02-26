require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  before(:each) do
    @user = mock(User)
    @user.stub!(:id).and_return(77)
    request.host = 'slate.local.host'
  end
  
  it "should render 'login' on GET to /login" do
    User.should_receive(:new).with(nil).and_return(@user)
    @user.should_receive(:new_record?).and_return(true)
    
    get 'login'
    response.should be_success
    response.should render_template('login')
    controller.resource.should == @user
  end
  
  it "should login with valid credentials and redirect to /spaces as non-super user, on POST to /login" do
    @credentials = { 'username' => 'cbscharf', 'password' => 'P@ssword' }
    User.should_receive(:login!).with(@credentials).and_return(@user)
    @user.should_receive(:super_user?).and_return(false)
    
    post 'login', :account => @credentials
    response.should be_redirect
    response.should redirect_to(spaces_url())
    session[:user_id].should == 77
  end
  
  it "should login with valid credentials and redirect to /dashboard as super user on POST to /login" do
    @credentials = { 'username' => 'cbscharf', 'password' => 'P@ssword' }
    User.should_receive(:login!).with(@credentials).and_return(@user)
    @user.should_receive(:super_user?).and_return(true)
    
    post 'login', :account => @credentials
    response.should be_redirect
    response.should redirect_to(dashboard_url())
    session[:user_id].should == 77
  end

  it "should login with valid credentials and redirect to http://www.google.com with custom redirect_to on POST to /login" do
    @credentials = { 'username' => 'cbscharf', 'password' => 'P@ssword' }
    User.should_receive(:login!).with(@credentials).and_return(@user)
    @user.should_receive(:super_user?).and_return(true)
    
    session[:redirect_to] = google = 'http://www.google.com'
    
    post 'login', :account => @credentials
    response.should be_redirect
    response.should redirect_to(google)
  end
  
  
  it "should render 'login' with invalid password on POST to /login" do
    @credentials = { 'username' => 'cbscharf', 'password' => 'p@ssworD'}
    User.should_receive(:login!).with(@credentials).and_raise(Slate::AccountInvalid)
    
    post 'login', :account => @credentials
    response.should be_success
    response.should render_template('login')
    assigns[:account].should have(1).errors
  end
  
  it "should render 'login' with invalid username on POST to /login" do
    @credentials = { 'username' => 'invalid', 'password' => 'p@ssworD'}
    User.should_receive(:login!).with(@credentials).and_raise(Slate::AccountInvalid)
    
    post 'login', :account => @credentials
    response.should be_success
    response.should render_template('login')
    assigns[:account].should have(1).errors
  end
end

describe AccountController, "when logged in" do
  before(:each) do
    @user = mock(User)
    session[:user_id] = 77
    request.host = 'slate.local.host'
  end
  
  it "should render show on GET to /" do
    User.should_receive(:find_by_id).with(77).and_return(@user)
    get 'show'
    response.should render_template('show')
  end
  
  it "should logout successfully" do
    User.active = @user
    get 'logout'
    response.should redirect_to(login_url)
    User.active.should == nil
  end
end

describe AccountController, "when not logged in" do
  before(:each) do
    @user = mock(User)
    session[:user_id] = 77
    request.host = 'slate.local.host'
  end
  
  it "should redirect to login on GET to /" do
    User.should_receive(:find_by_id).with(77).and_return(nil)
    get 'show'
    response.should redirect_to(login_url)
  end
end