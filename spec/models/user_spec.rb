require File.dirname(__FILE__) + '/../spec_helper'

module UserSpecHelper
  def create_user(options={})
    attributes = {
      :username      => 'scharfie',
      :first_name    => 'Chris',
      :initial       => 'B',
      :last_name     => 'Scharf',
      :email_address => 'scharfie@example.com',
      :reason_for_account => 'Cool people use slate.'
    }
    
    returning User.new(attributes.merge(options)) do |user|
      user.super_user = true if options[:super_user]
      user.save
    end
  end
  
  def request_account(options={})
    attributes = {
      :first_name => 'Samus',
      :last_name  => 'Aran',
      :username   => 'lsaran',
      :email_address => 'samus.aran@metroid.com',
      :reason_for_account => 'Cool people use slate.',
      :requested_on  => Time.local(1982, 9, 7, 17, 0, 0)
    }
    
    @user = User.request_account(attributes.merge(options))
  end  

  def unlock_account
    @user.locked = false
    @user.save
  end

  def verify_account
    @user.verified_on = Time.now
    @user.password = 'P@ssword'
    @user.save
  end  
  
  def approve_account
    @user.approved_on = Time.now
    @user.save
  end  
end

describe User do
  include UserSpecHelper
  fixtures :users
  
  it "should accept these passwords as valid" do
    ['Abcd1234',  # capital, lower,   number
     '###aaa111', # special, lower,   number
     'STEPHEN$0', # capital, special, number
     'Bobby#Sue'  # capital, lower,   special
    ].each { |p| User.valid_password?(p).should == true }
  end
  
  it "should reject these passwords as invalid" do
    ['abc',  # too short
     'abcd1234', # lower, number
     'ABCD1234', # upper, number
     'abcd####', # lower, special
     'ABCD####', # upper, special
     '####1234', # special, number
     'abcdEFGH', # lower, upper  
    ].each { |p| User.valid_password?(p).should == false }
  end
  
  it "should fail to set password attribute when invalid" do
    lambda { User.new(:password => 'invalid-password') }.
      should raise_error(Slate::PasswordInvalid)
  end
end

describe User, "requesting a new account" do
  include UserSpecHelper
  
  it "should succeed" do
    request_account
    @user.should_not == nil
    @user.should have(0).errors
    @user.username.should == 'lsaran'
    @user.verified?.should == false
    @user.approved?.should == false
    @user.verification_key.should == 'de1b937c7946744dad1d7f4fb2938054c15a2d56'
  end
  
  it "without username should assign a generated username" do
    @user = create_user(:username => nil, :first_name => 'Bruce',
      :initial => nil, :last_name => 'Wayne', 
      :email_address => 'brucewayne@example.com')

    @user.username.should == 'bwayne'
  end
  
  it "should assign a generated verification key" do
    @user = create_user
    @user.verified?.should == false
    @user.verification_key.should_not be_nil
  end
end

describe "Verifying an account" do
  include UserSpecHelper
  fixtures :users

  before(:each) do
    @su = create_user
    @su.update_attribute(:super_user, true)
  end  
  
  it "should fail because account is invalid" do
    verifying_an_invalid_account = lambda { User.verify_account('bad-username', 'bad-verify-key') }
    verifying_an_invalid_account.should raise_error(Slate::AccountInvalid)
  end
  
  it "should fail because verification key is invalid" do
    request_account
    verifying_with_invalid_key = lambda { User.verify_account('lsaran', 'bad-verify-key') }
    verifying_with_invalid_key.should raise_error(Slate::AccountVerificationInvalid)
  end  
  
  it "should succeed" do
    request_account
    @user.verified?.should == false
    @user.verified_on.should == nil
    User.verify_account('lsaran', 'de1b937c7946744dad1d7f4fb2938054c15a2d56')
    @user.reload
    @user.verified?.should == true
    @user.verified_on.should_not == nil
  end
end

describe "Approving an account" do
  include UserSpecHelper
  fixtures :users
  
  before(:each) do
    User.active = nil
    @su = create_user
    @su.update_attribute(:super_user, true)
  end
  
  it "should fail because account is invalid" do
    approving_an_invalid_account = lambda { User.approve_account('bad-username', '') }
    approving_an_invalid_account.should raise_error(Slate::AccountInvalid)
  end
  
  it "should fail because account is not verified" do
    request_account
    approving_an_unverified_account = lambda { User.approve_account('lsaran', '') }
    approving_an_unverified_account.should raise_error(Slate::AccountNotVerified)
  end
  
  it "should fail because super user is required for approval" do
    request_account && verify_account
    non_super_user_approving = lambda { User.approve_account('lsaran', @user.approval_key) }
    non_super_user_approving.should raise_error(Slate::SuperUserRequiredForApproval)
  end
  
  it "should fail because account is already approved" do
    request_account && verify_account && approve_account
    non_super_user_approving = lambda { User.approve_account('lsaran', '') }
    non_super_user_approving.should raise_error(Slate::AccountAlreadyApproved)
  end  
  
  it "should succeed" do
    request_account && verify_account
    User.active = @su
    
    approved_user = User.approve_account('lsaran', @user.approval_key)
    approved_user.should_not == nil
    approved_user.approved_by.should == 'scharfie'
    approved_user.approved_by.should == @su.username # sanity check
    approved_user.approved_on.should_not == nil
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

describe "New user" do
  include UserSpecHelper
  fixtures :users

  before(:each) do
    @user = create_user
    User.active = nil
  end

  it "should be a valid account" do
    @user.valid?.should == true
    @user.new_record?.should == false
    @user.id.should_not == nil
    @user.ldap_user?.should == false
    User.find(@user.id).should_not == nil
  end
  
  it "should have a temporary password" do
    @user.temporary_password = User.generate_password
    @user.temporary_password.should_not == nil
    @user.save
  end
  
  it "should have display_name 'Chris Scharf'" do
    @user.display_name.should == 'Chris Scharf'
  end
  
  it "should not be super user" do
    @user.super_user?.should == false
  end
  
  it "should not be locked" do
    @user.locked?.should == false
  end
  
  it "should be locked" do
    @user.lock_account
    @user.locked?.should == true
    @user.unlock_account
    @user.locked?.should == false
  end
  
  it "should not be verified" do
    @user.verified?.should == false
    proc = lambda do 
      User.verify_account(@user.username, 'invalid-key') 
    end
    proc.should raise_error(Slate::AccountVerificationInvalid)
  end
  
  it "should not be approved" do
    @user.approved?.should == false
  end
  
  it "should be verified" do
    User.verify_account(@user.username, @user.verification_key).should_not == nil
  end
end

describe User, "logging in" do
  include UserSpecHelper
  fixtures :users

  def login
    lambda { User.login('scharfie', 'P@ssword') }
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
  
  it "should fail because user not verified" do
    unlock_account && @user.save
    login.should raise_error(Slate::AccountNotVerified)
  end
  
  it "should fail because user not approved" do
    unlock_account && verify_account 
    login.should raise_error(Slate::AccountNotApproved)
  end
  
  it "should get locked out for exceeding login attempts" do
    unlock_account && verify_account && approve_account
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
    unlock_account && verify_account && approve_account
    invalid_login!.should raise_error(Slate::AccountInvalid)
  end
  
  it "should be invalid because wrong username provided" do
    User.login('bad-username', 'bad-password').should == nil
  end
  
  it "should login successfully" do
    unlock_account && verify_account && approve_account
    login.should change(User, :active).from(nil).to(@user)
  end
  
  it "should login via hash successfully" do
    unlock_account && verify_account && approve_account
    User.login(:username => 'scharfie', :password => 'P@ssword').should_not == nil
  end
  
  it "should login then logout successfully" do
    unlock_account && verify_account && approve_account
    login.should change(User, :active).from(nil).to(@user)
    logout.should change(User, :active).from(@user).to(nil)
  end
end

describe "Generating usernames for users" do
  def mock_user(first, initials, last)
    mu = mock('mock user')
    mu.should_receive(:first_name).any_number_of_times.and_return(first)  
    mu.should_receive(:initial).once.and_return(initials)  
    mu.should_receive(:last_name).once.and_return(last)
    mu
  end
  
  it "should return 'cbscharf' for Chris B Scharf" do
    mock = mock_user('Chris', 'B', 'Scharf')
    User.generate_username(mock).should == 'cbscharf'
  end
  
  it "should return 'cscharf' for Chris Scharf" do
    mock = mock_user('Chris', nil, 'Scharf')
    User.generate_username(mock).should == 'cscharf'
  end  
  
  it "should return 'bscharf' for Ben Scharf" do
    mock = mock_user('Ben', nil, 'Scharf')
    User.generate_username(mock).should == 'bscharf'
  end  
end

describe User, "approval" do
  include UserSpecHelper
  
  before(:each) do
    @su = create_user
    @su.update_attribute(:super_user, true)

    request_account(:username => 'aglenn')
    @user.update_attribute(:verified_on, Time.local(2007, 1, 1, 0, 0, 0))
  end
  
  it "should have proper approval key" do
    @user.approval_key.should == "0ebe1612141e62f4464583901dd1a6226a843eed"
  end
  
  it "should become approved" do
    User.active = @su
    User.approve_account('aglenn', "0ebe1612141e62f4464583901dd1a6226a843eed")
    
    @user.reload
    @user.should be_approved
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