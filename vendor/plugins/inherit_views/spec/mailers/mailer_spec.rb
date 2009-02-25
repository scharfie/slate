require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe 'Mailer specs' do
  before :all do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
  end
  
  before :each do
    ActionMailer::Base.deliveries.clear
  end
  
  describe NormalMailer do
    before :each do
      NormalMailer.deliver_email
      @deliveries = ActionMailer::Base.deliveries
    end
  
    it "should deliver email" do
      @deliveries.size.should == 1
    end
    
    it "should render email with partial" do
      @deliveries.first.body.should == "normal_mailer:email\nnormal_mailer:_partial"
    end
  end
  
  describe InheritingMailer do
    before :each do
      InheritingMailer.deliver_email
      @deliveries = ActionMailer::Base.deliveries
    end
  
    it "should deliver email" do
      @deliveries.size.should == 1
    end
    
    it "should render email with inherited partial" do
      @deliveries.first.body.should == "inheriting_mailer:email\nnormal_mailer:_partial"
    end
  end
end