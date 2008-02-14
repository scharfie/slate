require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :NavigationTestController) rescue

class NavigationTestController < ActionController::Base
  include Slate::Navigation
end

describe 'Slate::NavigationTest' do
  controller_name 'NavigationTest'

  before(:each) do
    controller.class.current_tab = nil
  end

  it "should return default 'NavigationTest' for current tab" do
    controller.class.current_tab.should == 'NavigationTest'
  end

  it "should set current tab to 'Pages'" do
    controller.class.current_tab 'Pages'
    controller.class.current_tab.should == 'Pages'
  end
  
  it "should access current tab via helper method" do
    controller.class.current_tab 'Pages'
    controller.current_tab.should == 'Pages'
  end
end