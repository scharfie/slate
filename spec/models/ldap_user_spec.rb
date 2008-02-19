require File.dirname(__FILE__) + '/../spec_helper'

if perform_ldap_testing?

def testuser
  Slate.config.ldap.testuser
end

module LdapUserSpecHelper
  def create_ldap_user(options={})
    attributes = { :username => testuser.username }
    @user = LdapUser.new(attributes.merge(options))
    @user.save
  end
  
  def unlock_account
    @user.locked = false
    @user.save!
  end
  
  def verify_account
    @user.verified_on = Time.now
    @user.password = @user.password_confirmation = 'P@ssword'
    @user.save!
  end  
  
  def approve_account
    @user.approved_on = Time.now
    @user.save!
  end
  
  def request_ldap_account(options={})
    attributes = {
      :first_name => 'Samus',
      :last_name  => 'Aran',
      :username   => 'lsaran',
      :email_address => 'samus.aran@metroid.com',
      :reason_for_account => 'Cool people use slate.',
      :requested_on  => Time.local(1982, 9, 7, 17, 0, 0)
    }
    
    LdapUser.request_account(attributes.merge(options))
  end  
end

describe "LdapUser '#{testuser.display_name}'" do
  include LdapUserSpecHelper
  fixtures :users
  
  before(:each) do
    create_ldap_user
  end
  
  it "should be valid" do
    @user.valid?.should == true
  end
  
  it "should be a system user" do
    @user.ldap_user?.should == true
  end
 
  it "should be found via username" do
    Slate::LDAP.find_by_username(testuser.username).should_not == nil
  end
  
  it "should be found via email address" do
    Slate::LDAP.find_by_email_address(testuser.email_address).should_not == nil
  end

  it "should have first name '#{testuser.first_name}'" do
    @user.first_name.should == testuser.first_name
  end
  
  it "should have last name '#{testuser.last_name}'" do
    @user.last_name.should == testuser.last_name
  end
  
  it "should have display name '#{testuser.display_name}'" do
    @user.display_name.should == testuser.display_name
  end
  
  it "should have email address '#{testuser.email_address}'" do
    @user.email_address.should == testuser.email_address
  end
end

describe "LdapUser 'batman' logging in" do
  include LdapUserSpecHelper
  fixtures :users

  def login
    lambda { User.login(testuser.username, testuser.password) }
  end
  
  before(:each) do
    create_ldap_user
    @user.update_attribute(:locked, true)
  end
  
  it "should fail because account is locked" do
    login.should raise_error(Slate::AccountLocked)
  end
  
  it "should fail because account not verified" do
    unlock_account
    login.should raise_error(Slate::AccountNotVerified)
  end
  
  it "should fail because account not approved" do
    unlock_account && verify_account
    login.should raise_error(Slate::AccountNotApproved)
  end
  
  it "should fail with incorrect password" do
    unlock_account && verify_account && approve_account
    User.login(testuser.username, 'wrong-password').should == false
  end  
  
  it "should succeed with correct password" do
    unlock_account && verify_account && approve_account
    User.login(testuser.username, testuser.password).should_not == nil
  end
end

describe LdapUser, "requesting an account" do
  include LdapUserSpecHelper
  fixtures :users
  
  it "should fail because username is invalid" do
    Slate::LDAP.should_receive(:find_by_username_or_email_address).
      with('fake-user').and_return(false)
      
    @user = request_ldap_account(:username => 'fake-user')
    @user.should be_ldap_user
    @user.errors[:username].should == 'does not appear to be valid'
  end
end

# describe LdapUser, "'fake-user'" do
#   include LdapUserSpecHelper
#   fixtures :users
# 
#   before(:each) do
#     create_ldap_user(:username => 'fake-user')
#   end
#   
#   it "should not have a first name" do
#     @user.first_name.should == nil    
#   end
# end  
# 
# describe "Invalid LdapUser requesting an account" do
#   include LdapUserSpecHelper
#   fixtures :users
#   
#   it "should not succeed" do
#     @user = LdapUser.request_account(:username => 'fake-user')
#     @user.new_record?.should == true
#     @user.errors.on('username').should == 'does not appear to be valid'
#   end
# end

end # perform_ldap_testing?