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