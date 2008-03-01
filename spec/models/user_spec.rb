require File.dirname(__FILE__) + '/../spec_helper'

module UserSpecHelper
  def create_user(options={})
    attributes = {
      :username      => 'scharfie',
      :password      => 'P@ssword',
      :password_confirmation => 'P@ssword',
      :first_name    => 'Chris',
      :initial       => 'B',
      :last_name     => 'Scharf',
      :email_address => 'scharfie@example.com'
    }
    
    returning User.new(attributes.merge(options)) do |user|
      user.super_user = true if options[:super_user]
      user.save
    end
  end
  
  def unlock_account
    @user.unlock_account
  end
end

describe "User 'cbscharf'" do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    User.active = users(:cbscharf)
  end

  it "should have display name 'Chris Scharf'" do
    User.active.display_name.should == 'Chris Scharf'
  end
  
  it "should be found by username 'cbscharf'" do
    User.find_user('cbscharf').should == User.active
  end
  
  it "should be found by id=1" do
    User.find_user(1).should == User.active
  end
end

describe "User becoming a member of a space" do
  fixtures :users, :spaces, :memberships
  
  before(:each) do
    User.active = users(:cbscharf)
  end
  
  it "should have role == 1 for 'test_space'" do
    space = spaces(:test_space)
    User.active.spaces.find(space.id).role.should == 1

    User.active.reload
    User.active.role(space).should == 1
  end
  
  it "should have role == 2 for 'admin_space'" do
    space = spaces(:admin_space)
    User.active.spaces.find(space.id).role.should == 2
    
    User.active.reload
    User.active.role(space).should == 2
  end
end

describe User, "logging in" do
  include UserSpecHelper
  fixtures :users

  def login
    lambda { User.login!('scharfie', 'P@ssword') }
  end

  def invalid_login 
    lambda { User.login('scharfie', 'badpassword'); @user.reload }
  end

  def invalid_login!
    lambda { User.login!('scharfie', 'badpassword'); @user.reload }
  end
  
  def logout
    lambda { @user.logout }
  end

  before(:each) do
    @user = create_user
    @user.locked = true
    @user.save
    
    User.active = nil
  end
  
  it "should fail because account is locked" do
    @user.locked?.should == true
    login.should raise_error(Slate::AccountLocked)
  end
  
  
  it "should get locked out for exceeding login attempts" do
    unlock_account
    invalid_login.should change(@user, :login_attempts).from(0).to(1)
    invalid_login.should change(@user, :login_attempts).from(1).to(2)
    invalid_login.should change(@user, :login_attempts).from(2).to(3)
    invalid_login.should change(@user, :login_attempts).from(3).to(4)
    invalid_login.should raise_error(Slate::AccountLocked)
  end
  
  it "should raise an exception on login! with invalid username" do
    lambda { User.login!('bad-username', 'bad-password') }.should raise_error(Slate::AccountInvalid)
  end
  
  it "should raise an exception on login! with wrong password" do
    unlock_account
    invalid_login!.should raise_error(Slate::AccountInvalid)
  end
  
  it "should be invalid because wrong username provided" do
    User.login('bad-username', 'bad-password').should == nil
  end
  
  it "should login successfully" do
    unlock_account
    login.should change(User, :active).from(nil).to(@user)
  end
  
  it "should login via hash successfully" do
    unlock_account
    User.login(:username => 'scharfie', :password => 'P@ssword').should_not == nil
  end
  
  it "should login then logout successfully" do
    unlock_account
    login.should change(User, :active).from(nil).to(@user)
    logout.should change(User, :active).from(@user).to(nil)
  end
end

describe User do
  include UserSpecHelper
  fixtures :users
  
  before(:each) do
    User.active = nil
    @su = create_user(:email_address => 'cbscharf@su.example.com')
    @su.update_attribute(:super_user, true)
  end
  
  it "should return super user email addresses in array" do
    User.super_user_email_addresses.should == ['cbscharf@su.example.com']
  end
end

# describe "User 'cbscharf' logged into 'Test Space'" do
#   include UserSpecHelper
#   fixtures :users, :spaces, :memberships
# 
#   before(:each) do
#     User.active   = (@user = users(:cbscharf))
#     Space.active = (@space = spaces(:test_space))
#   end
#   
#   it "should raise CurrentSpaceError when checking site admin" do
#     Space.active = nil
#     site_admin_check = lambda { @user.site_admin? }
#     site_admin_check.should raise_error(Slate::CurrentSpaceError)
#   end
#   
#   it "should have permissions checked" do
#     @user.super_user?.should == false
#     @user.site_admin?.should == false
#     @user.check_permissions?.should == true
#   end
# end

describe User do
  include UserSpecHelper
  fixtures :users
  
  before(:each) do
    # freeze time
    @time = Time.now; Time.stub!(:now).and_return(@time)
    @expires_at = 2.weeks.from_now.utc
    
    @user  = users(:cbscharf)
    @user.remember_me!

    @token = @user.remember_token
  end
  
  it "should return true for remember_me?" do
    @user.remember_me = '1'
    @user.should be_remember_me
    @user.remember_me = 1
    @user.should be_remember_me
  end
  
  it "should return false for remember_me?" do
    @user.should_not be_remember_me
    @user.remember_me = 0
    @user.should_not be_remember_me
  end 

  it "should be remembered" do
    User.find_by_remember_token(@token).should == @user
    @user.remember_token_expires_at.should == @expires_at
  end
  
  it "should be remembered for 3 days" do
    @user.remember_me_for(3.days)
    @user.remember_token_expires_at.should == 3.days.from_now.utc
  end
  
  it "should be forgotten" do
    @user.forget_me!
    @user.remember_token.should be_nil
    User.find_by_remember_token(@token).should be_nil
  end
  
  it "should have remember_token_as_cookie when remembered" do
    @user.remember_token_as_cookie.should == {
      :value => @token, :expires => @expires_at
    }
  end
  
  it "should have remember_token_as_cookie when forgotten" do
    @user.forget_me!
    @user.remember_token_as_cookie.should be_nil
  end
end