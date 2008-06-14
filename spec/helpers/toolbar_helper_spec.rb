require File.dirname(__FILE__) + '/../spec_helper'

describe ToolbarHelper do
  
  before(:each) do
    helper.toolbar_collection.items.clear
    helper.toolbar_collection.items('actions').clear
  end
  
  it "should return toolbar collectible" do
    helper.toolbar_collection.should be_a_kind_of(Slate::Collectible)
  end
  
  it "should return 'toolbar' for key" do
    helper.toolbar_collection.key.should == 'toolbar'
  end
  
  it "should create new toolbar item using text" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_item 'Dashboard'
    helper.toolbar_collection.items.first.should == 'Dashboard'
  end
  
  it "should create new toolbar item using block" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_item { 'Dashboard' }
      
    helper.toolbar_collection.items.first.should == 'Dashboard'
  end

  it "should create new toolbar item using text and block" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_item('Administrator ') { 'Dashboard' }
      
    helper.toolbar_collection.items.first.should == 'Administrator Dashboard'
  end

  it "should create toolbar link item using toolbar_link" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_link 'Google', 'http://www.google.com'
    helper.toolbar_collection.items.first.should == '<a href="http://www.google.com">Google</a>'
  end
  
  it "should create new toolbar item in 'actions' toolbar" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_collection.items('actions').should be_empty

    helper.toolbar_item 'actions', 'New page'

    helper.toolbar_collection.items.should be_empty
    helper.toolbar_collection.items('actions').first.should == 'New page'
  end
  
  it "should create new toolbar item in 'actions' toolbar covertly" do
    helper.toolbar_collection.items.should be_empty
    helper.toolbar_collection.items('actions').should be_empty
    helper.toolbar_collection.keys.push 'actions'
    helper.toolbar_collection.items.should be_empty

    helper.toolbar_item 'actions', 'New page'

    helper.toolbar_collection.items.first.should == 'New page'
    helper.toolbar_collection.keys.pop
    helper.toolbar_collection.items('actions').first.should == 'New page'
    helper.toolbar_collection.items.should be_empty
  end  
  
  it "should create new toolbar" do
    helper.toolbar_item 'View'
    helper.toolbar_collection.should have(1).items

    helper.toolbar_item 'Edit'
    helper.toolbar_collection.should have(2).items
    
    result = helper.toolbar
    result.should include('<ul class="toolbar">')
    result.should include('<li>View</li>')
    result.should include('<li class="separator">|</li>')
    result.should include('<li>Edit</li>')
  end
end
