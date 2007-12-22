require File.dirname(__FILE__) + '/../spec_helper'

describe AccountMailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    ActionController::Integration::Session.stub!(:controller_path).and_return('')

    @controller = ActionController::Integration::Session.new
    @user = mock(User)
  end
  
  it "verification email should be delivered to requester" do
    @user.should_receive(:first_name).and_return('Christopher')
    @user.should_receive(:email_address).and_return('scharfie@example.com')
    @user.should_receive(:verification_key).and_return('6c60cf262c63585c60c6cd13a9e85c5aa9704b07')
    @user.should_receive(:id).and_return(77)
    
    AccountMailer.deliver_verify(@controller, @user)
    ActionMailer::Base.deliveries.should_not be_empty

    sent = ActionMailer::Base.deliveries.first
    sent.to.should == ['scharfie@example.com']
    sent.subject.should == 'slate Account request (Response needed)'
    
    sent.body.should include("Dear Christopher,")
    sent.body.should include(
      "http://www.example.com/account/verify/77/6c60cf262c63585c60c6cd13a9e85c5aa9704b07"
    )
  end
  
  it "verified email should be delivered to super users" do
    User.should_receive(:super_user_email_addresses).and_return(['cbscharf@su.example.com'])
    @user.should_receive(:username).exactly(2).and_return('scharfie')
    @user.should_receive(:why).and_return('Testing the verified email process')
    @user.should_receive(:approval_key).and_return('4285497cd59c95bec36bb58b0b4cb794027f7726')
    @user.should_receive(:display_name).and_return('Chris Scharf')
    @user.should_receive(:id).and_return(77)
    
    AccountMailer.deliver_verified(@controller, @user)
    ActionMailer::Base.deliveries.should_not be_empty

    sent = ActionMailer::Base.deliveries.first
    sent.to.should == ['cbscharf@su.example.com']
    sent.subject.should == 'slate Account verified (scharfie)'
    
    sent.body.should include("Chris Scharf (scharfie)")
    sent.body.should include("Testing the verified email process")
    sent.body.should include(
      "http://www.example.com/account/approve/77/4285497cd59c95bec36bb58b0b4cb794027f7726"
    )
  end
  
  it "approved email should be delivered to requester" do
    @user.should_receive(:username).and_return('scharfie')
    @user.should_receive(:first_name).and_return('Christopher')
    @user.should_receive(:email_address).and_return('scharfie@example.com')
    @user.should_receive(:ldap_user?).and_return(false)
    @user.should_receive(:temporary_password).and_return('P@ssword')
    
    AccountMailer.deliver_approved(@controller, @user)
    ActionMailer::Base.deliveries.should_not be_empty

    sent = ActionMailer::Base.deliveries.first
    sent.to.should == ['scharfie@example.com']
    sent.subject.should == 'slate Account approved'
    
    sent.body.should include("Dear Christopher,")
    sent.body.should include("http://www.example.com/login")
    sent.body.should include("P@ssword")
  end
end