require File.dirname(__FILE__) + '/../spec_helper'
require 'ostruct'

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

describe Space, "with plugins A, B, and C" do
  fixtures :spaces, :pages, :plugins
  
  before(:each) do
    Slate.plugins = [
      OpenStruct.new(:key => 'A'),
      OpenStruct.new(:key => 'B'),
      OpenStruct.new(:key => 'C')
    ]
    
    @space = spaces(:test_space) 
    @space.plugins = %w(A B C)
  end
  
  it "should have 3 plugins" do
    @space.should have(3).plugins
  end
  
  it "should disable plugin B" do
    @space.plugins = %w(A C)
    @space.plugins.select(&:enabled?).map(&:key).should == %w(A C)
  end
  
  it "should enable new plugin D" do
    Slate.plugins << OpenStruct.new(:key => 'D')
    @space.plugins = %w(A B C D)
    @space.should have(4).plugins
    @space.plugins.select(&:enabled?).map(&:key).should == %w(A B C D)
  end
  
  it "should disable new plugin E" do
    Slate.plugins << OpenStruct.new(:key => 'E')
    @space.should have(4).available_plugins
    
    @space.plugins = %w(A B C)
    @space.plugins.reject(&:enabled?).map(&:key).should == %w(E)
  end
end