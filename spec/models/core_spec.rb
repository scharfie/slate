require File.dirname(__FILE__) + '/../spec_helper'

describe 'String#permalink' do
  mappings = {
    "this_is_a_test_page" => "This Is a Test Page!",
    "my_goodness_that_s_crazy" => "My goodness!!  That's CRAZY"
  }
  
  mappings.each do |expected, original|
    it "should return #{expected} for permalink('_') on #{original}" do
      original.permalink('_').should == expected
    end
  end
  
  it "should return sample-blog-entry for permalink on Sample BLOG Entry" do
    "Sample BLOG Entry".permalink.should == "sample-blog-entry"
  end 
end

describe 'String#/' do
  mappings = {
    "Users/Chris/Sites/slate", ['Users/Chris', 'Sites/slate'],
    "/opt/local/bin/ruby", ['/opt/', 'local/bin/ruby']
  }
  
  mappings.each do |expected, original|
    it "should return #{expected} for / on #{original.inspect}" do
      (original[0] / original[1]).should == expected
    end
  end
end

describe 'Object#try' do
  before(:each) do
    @object = Object.new
  end
  
  it "should fail on message 'invalid_message'" do
    # there's no "real" way to test a failure for try...
    # adding should_not_receive makes the object respond to
    # that message, so we just have to assume it failed :/
    @object.try(:invalid_message).should == nil
    @object.respond_to?(:invalid_message).should == false
  end
  
  it "should pass on message 'valid_message'" do
    @object.stub!(:valid_message).and_return('Passed')
    @object.try(:valid_message).should == 'Passed'
  end
end

describe 'Hash#+' do
  it "should add two hashes" do
    first = { :first => 'Chris' }
    last  = { :last  => 'Scharf' }
    name = first + last
    
    name.keys.should == [:first, :last]
  end
end