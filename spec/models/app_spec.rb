require File.dirname(__FILE__) + '/../spec_helper'

describe App do
  it "should not be development environment" do
    App.should_not be_development
  end

  it "should not be production environment" do
    App.should_not be_production
  end

  it "should be test environment" do
    App.should be_test
  end
  
  it "should have root == #{Rails.root}" do
    App.root.should == Rails.root
  end
end