require File.dirname(__FILE__) + '/../spec_helper'

describe Space do
  fixtures :spaces, :pages
  
  before(:each) do
    @space = spaces(:test_space) 
    @space2 = spaces(:admin_space) 
  end
  
  it "should create root page" do
    @space.pages.find_root.should be_nil
    @root = @space.pages.create_root
    @root.should_not be_nil
    @root.should_not be_new_record
    @space.pages.find_root.should == @root
    
    @space2.pages.find_root.should be_nil
    @root2 = @space2.pages.create_root
    @root2.should_not be_nil
    @root2.should_not be_new_record
    @space2.pages.find_root.should == @root2
    
    @space2.pages.find_root.should_not == @root
    @space.pages.find_root.should_not == @root2
  end
end