require File.dirname(__FILE__) + '/../spec_helper'

describe ToolbarHelper do
  attr_accessor :erb_output
  
  before(:each) do
    self.erb_output = ''
  end
  
  it "should return toolbar collectible" do
    toolbar_collection.should be_a_kind_of(Slate::Collectible)
  end
  
  it "should return 'toolbar' for key" do
    toolbar_collection.key.should == 'toolbar'
  end
  
  it "should create new toolbar item using text" do
    toolbar_collection.items.should be_empty
    toolbar_item 'Dashboard'
    toolbar_collection.items.first.should == 'Dashboard'
  end
  
  it "should create new toolbar item using block" do
    toolbar_collection.items.should be_empty
    toolbar_item { 'Dashboard' }
      
    toolbar_collection.items.first.should == 'Dashboard'
  end

  it "should create new toolbar item using text and block" do
    toolbar_collection.items.should be_empty
    toolbar_item('Administrator ') { 'Dashboard' }
      
    toolbar_collection.items.first.should == 'Administrator Dashboard'
  end
  
  it "should create new toolbar item in 'actions' toolbar" do
    toolbar_collection.items.should be_empty
    toolbar_collection.items('actions').should be_empty

    toolbar_item 'actions', 'New page'

    toolbar_collection.items.should be_empty
    toolbar_collection.items('actions').first.should == 'New page'
  end
  
  it "should create new toolbar item in 'actions' toolbar covertly" do
    toolbar_collection.items.should be_empty
    toolbar_collection.items('actions').should be_empty
    toolbar_collection.keys.push 'actions'
    toolbar_collection.items.should be_empty

    toolbar_item 'actions', 'New page'

    toolbar_collection.items.first.should == 'New page'
    toolbar_collection.keys.pop
    toolbar_collection.items('actions').first.should == 'New page'
    toolbar_collection.items.should be_empty
  end  
  
  it "should create new toolbar" do
    toolbar_item 'View'
    toolbar_collection.should have(1).items

    toolbar_item 'Edit'
    toolbar_collection.should have(2).items
    
    result = toolbar
    result.should include('<ul class="toolbar">')
    result.should include('<li>View</li>')
    result.should include('<li class="separator">|</li>')
    result.should include('<li>Edit</li>')
  end
end
