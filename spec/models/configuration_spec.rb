require File.dirname(__FILE__) + '/../spec_helper'

describe Slate::Configuration do
  it "should be accessible directly" do
    Slate::Configuration.new_namespace.should_be Slate::ConfigurationHash
  end
  
  it "should create new settings via block" do
    Slate::Configuration.config do |config|
      config.new_namespace.first_name = 'Chris'
      config.new_namespace.last_name = 'Scharf'
    end
    
    Slate::Configuration.new_namespace.first_name.should == 'Chris'
    Slate::Configuration.new_namespace.last_name.should == 'Scharf'
  end
  
  it "should be accessible via Slate.config" do
    Slate.config.should == Slate::Configuration.config
    Slate.config.should == Slate::Configuration.settings
  end
end

describe Slate::ConfigurationHash do
  before(:each) do
    @config = Slate::ConfigurationHash.new
  end
  it "should create new namespaces automatically" do
    @config.default(:new_namespace).should_be Slate::ConfigurationHash
    @config.new_namespace.should_be Slate::ConfigurationHash
  end
  
  it "should allow passing a block to define settings within namespace" do
    @config.cbscharf do |cbscharf|
      cbscharf.first_name = 'Chris'
      cbscharf.last_name  = 'Scharf'
      
      cbscharf.address do |address|
        address.city = 'Morgantown'
        address.state = 'WV'
      end
    end
    
    @config.cbscharf.first_name.should == 'Chris'
    @config.cbscharf.last_name.should == 'Scharf'
    @config.cbscharf.address.city.should == 'Morgantown'
    @config.cbscharf.address.state.should == 'WV'
  end
end