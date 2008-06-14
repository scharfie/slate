require File.dirname(__FILE__) + '/../spec_helper'

describe NavigationHelper do
  attr_accessor :render_options
  
  before(:each) do
    @user = mock(User)
    assigns[:controller] = self
  end
  
  it "as super user, no active space, should get admin navigation items" do
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:active).at_least(1).and_return(nil)
    @user.should_receive(:super_user?).and_return(true)
    
    @items = helper.send :items_for_navigation
    @items.should have(1).items
  end

  it "as super user, with active space, should get space navigation items" do
    @space = mock(Space)
    @space.stub!(:id).and_return(133)
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:active).at_least(1).and_return(@space)
    
    helper.should_receive(:space_dashboard_path).with(Space.active)
    helper.should_receive(:edit_space_path).with(Space.active)
    helper.should_receive(:space_assets_path).with(Space.active)
    helper.should_receive(:plugin_navigation_items).and_return([])
    
    @items = helper.send :items_for_navigation
    @items.should have(4).items
  end
  
  it "should render nothing with no active user" do
    User.should_receive(:active).and_return(nil)
    helper.should_not_receive(:render)
    helper.navigation.should be_nil
  end
  
  it "should render shared navigation" do
    helper.should_receive(:items_for_navigation).and_return([1,2,3])
    helper.should_receive(:render).with(:object => [1,2,3], :partial => 'shared/navigation')
    helper.navigation
  end
end

describe NavigationHelper, "navigation items" do
  it "should create link to navigation item 'Pages'" do
    helper.should_receive(:current_tab).and_return('Pages')
    helper.navigation_item('Pages', space_pages_path(1)).
      should == '<a href="/spaces/1/pages" class="current">Pages</a>'
  end
end

describe NavigationHelper, "plugin navigation items" do
  it "should return navigation items from plugins" do
    @navigation_definitions = Proc.new { |tabs| 
      tabs.add "Login", '/login'
    }
    
    @plugin = mock(Plugin)
    @plugin.stub!(:enabled?).and_return(true)
    @plugin.stub!(:navigation_definitions).
      and_return([@navigation_definitions])

    Space.should_receive(:active).and_return(@space = mock(Space))
    @space.should_receive(:available_plugins).and_return([@plugin])
    
    items = helper.send :plugin_navigation_items
    items.should == [['Login', '/login']]
  end
end