require File.dirname(__FILE__) + '/../spec_helper'

describe NavigationHelper do
  attr_accessor :render_options
  
  before(:each) do
    @user = mock(User)
  end
  
  def render(*args)
    self.render_options = *args
  end
  
  it "as super user, no active space, should get admin navigation items" do
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:active).at_least(1).and_return(nil)
    @user.should_receive(:super_user?).and_return(true)
    
    @items = items_for_navigation
    @items.should have(1).items
  end

  it "as super user, with active space, should get space navigation items" do
    @space = mock(Space)
    @space.stub!(:id).and_return(133)
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:active).at_least(1).and_return(@space)
    
    should_receive(:space_dashboard_path).with(Space.active)
    should_receive(:edit_space_path).with(Space.active)
    should_receive(:space_assets_path).with(Space.active)
    
    @items = items_for_navigation
    @items.should have(4).items
  end
  
  it "should render nothing with no active user" do
    User.should_receive(:active).and_return(nil)
    navigation.should be_nil
  end
  
  it "should render shared/navigation" do
    @space = mock(Space)
    @space.stub!(:id).and_return(133)
    User.should_receive(:active).at_least(1).and_return(@user)
    Space.should_receive(:active).at_least(1).and_return(@space)

    should_receive(:space_dashboard_path).with(Space.active)
    should_receive(:edit_space_path).with(Space.active)

    navigation.should_not be_nil
    render_options[:partial].should == 'shared/navigation'    
  end
end

describe NavigationHelper, "navigation items" do
  before(:each) do
    controller.stub!(:controller_name).and_return('pages')
  end
  
  def controller
    @controller
  end
  
  it "should create link to navigation item 'Pages'" do
    should_receive(:current_tab).and_return('Pages')
    
    navigation_item('Pages', space_pages_path(1)).
      should == '<a href="/spaces/1/pages" class="current">Pages</a>'    
  end
end