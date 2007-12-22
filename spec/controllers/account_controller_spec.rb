require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  before(:each) do
    @user = mock(User)
    @user.stub!(:id).and_return(77)
  end
  
  it "should render 'login' on GET to /login" do
    User.should_receive(:new).with(nil).and_return(@user)
    
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
  end
  
  it "should redirect to login on GET to /" do
    User.should_receive(:find_by_id).with(77).and_return(nil)
    get 'show'
    response.should redirect_to(login_url)
  end
end

describe AccountController, 'new account request' do
  before(:each) do
    @user = mock(User)
    @account_params = {
      'username' => 'chrisscharf', 
      'first_name' => 'Chris',
      'last_name' => 'Scharf',
      'email_address' => 'chrisscharf@example.com',
      'reason_for_account' => 'Cool people use slate.'
    }
    
    @logged_in_user = mock(User)
    
    request.host = 'www.example.com'
  end
  
  it "should render 'new' on GET to /new" do
    get 'new'
    response.should render_template('new')
  end
  
  it "should send verification email and redirect when valid on POST to /create" do

    @user.should_receive(:save).and_return(true)
    @user.should_receive(:email_address).and_return('chrisscharf@example.com')
    User.should_receive(:new).with(@account_params).and_return(@user)

    # send_verification_email called...
    AccountMailer.should_receive(:deliver_verify).with(controller, @user)
    
    post 'create', :account => @account_params
    response.should redirect_to(login_url)
    flash[:notice].should == 'Successfully requested account!  Email sent to chrisscharf@example.com'
    assigns[:account].should == @user
  end
  
  it "should render 'new' when invalid on POST to /create" do
    @user.should_receive(:save).and_return(false)
    User.should_receive(:new).with(@account_params).and_return(@user)
    
    post 'create', :account => @account_params
    response.should render_template('new')
  end
  
  it "should redirect to 'login' when invalid on GET to /verify" do
    User.should_receive(:verify_account).with('77', 'de1b937c7946744dad1d7f4fb2938054c15a2d56').
      and_raise(Slate::UserError)
    
    get 'verify', :id => 77, :key => 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
    
    response.should be_redirect
    response.should redirect_to(login_url)
    flash[:notice].should be_nil
    flash[:error].should_not be_nil
  end  
  
  it "should send verified email and redirect when valid on GET to /verify" do
    User.should_receive(:verify_account).with('77', 'de1b937c7946744dad1d7f4fb2938054c15a2d56').
      and_return(@user)
    
    AccountMailer.should_receive(:deliver_verified).with(controller, @user)
    
    get 'verify', :id => 77, :key => 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
    
    response.should be_redirect
    response.should redirect_to(login_url)
    flash[:notice].should == 'Successfully verified account!  You may login once your account has been approved.'  
    flash[:error].should == nil
  end
  
  it "should redirect to 'login' when no super user logged in on GET to /approve" do
    User.should_receive(:find_by_id).and_return(@logged_in_user)
    @logged_in_user.should_receive(:super_user?).and_return(false)
    
    get 'approve', :id => 77, :key => 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
    
    response.should be_redirect
    response.should redirect_to(login_url)
    session[:redirect_to].should == 'http://www.example.com/account/approve/77/de1b937c7946744dad1d7f4fb2938054c15a2d56'
    flash[:error].should == 'Super user is required to perform this task.'
    flash[:notice].should == nil
  end  
  
  it "should redirect to 'login' when invalid on GET to /approve" do
    User.should_receive(:approve_account).with('77', 'de1b937c7946744dad1d7f4fb2938054c15a2d56').
      and_raise(Slate::UserError)

    User.should_receive(:find_by_id).and_return(@logged_in_user)
    @logged_in_user.should_receive(:super_user?).and_return(true)
    
    get 'approve', :id => 77, :key => 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
    
    response.should be_redirect
    response.should redirect_to(login_url)
    session[:redirect_to].should be_nil
    flash[:error].should_not == 'Super user is required to perform this task.'
    flash[:notice].should be_nil
  end   
  
  it "should send approved email and redirect when valid on GET to /approve" do
    User.should_receive(:approve_account).with('77', 'de1b937c7946744dad1d7f4fb2938054c15a2d56').
      and_return(@user)
    
    User.should_receive(:find_by_id).and_return(@logged_in_user)
    @logged_in_user.should_receive(:super_user?).and_return(true)
    
    AccountMailer.should_receive(:deliver_approved).with(controller, @user)
    
    get 'approve', :id => 77, :key => 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
    
    response.should be_redirect
    response.should redirect_to(login_url)
    flash[:notice].should == 'Successfully approved account!'
    flash[:error].should == nil
  end
end