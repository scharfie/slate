require File.dirname(__FILE__) + '/../spec_helper'

Object.send :remove_const, :PermalinkColumnTestClass rescue nil

class PermalinkColumnTestClass
  include Slate::PermalinkColumn
  attr_accessor :name
  
  def [](attr)
    self.instance_variable_get("@#{attr}")
  end
  
  def []=(attr, value)
    self.instance_variable_set("@#{attr}", value)
  end
  
  def self.before_save(*args); end
end

describe 'Slate::PermalinkColumn' do
  before(:each) do
    @klass = PermalinkColumnTestClass.new
  end
  
  it "should create permalink using name" do
    @klass.class.permalink_column :name
    @klass.name = 'A Permalink Test'
    @klass.permalink.should == 'a_permalink_test'
  end

  it "should create permalink using name with '-' as glue" do
    @klass.class.permalink_column :name, :glue => '-'
    @klass.name = 'A Permalink Test'
    @klass.permalink.should == 'a-permalink-test'
  end
  
end