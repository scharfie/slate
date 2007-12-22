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
  
  it "should prepare options for navigation item 'Custom'" do
    should_receive(:hash_for_space_custom_url).and_return(:controller => 'custom_controller')
    @options = options_for_navigation_item('Custom')
    @options[:url].should == { :controller =>'custom_controller' }
    @options[:name].should == 'Custom'
    @options[:class].should be_nil
  end
  
  it "should prepare current navigation item 'Pages'" do
    should_receive(:hash_for_space_pages_url).and_return(:controller => 'pages')
    @options = options_for_navigation_item('Pages')
    @options[:url].should == { :controller => 'pages' }
    @options[:name].should == 'Pages'
    @options[:html][:class].should == 'current'
    
    navigation_item_current?(@options).should == true
  end
  
  it "should prepare current navigation for item 'Dashboard' with exact matching" do
    stub!(:url_for).and_return('spaces/1/dashboard')
    should_receive(:hash_for_space_dashboard_url).and_return(:controller => 'dashboard')
    
    @options = options_for_navigation_item('Dashboard', :match => :exact)
    @options[:url].should == { :controller => 'dashboard' }
    @options[:name].should == 'Dashboard'
    @options[:html][:class].should == 'current'
    
    navigation_item_current?(@options).should == true
  end
  
  it "should prepare navigation item 'Assets' with custom options" do
    @options = options_for_navigation_item('Assets', :url => { :controller => 'my_assets' },
      :matches => 'files', :name => 'My Assets', :html => { :id => 'myAssets' })
    @options[:url].should == { :controller => 'my_assets' }
    @options[:name].should == 'My Assets'
    @options[:html].should == { :id => 'myAssets' }
  end
  
  it "should create link to navigation item 'Pages'" do
    should_receive(:hash_for_space_pages_url).and_return(:controller => 'pages')
    @link = navigation_item('Pages')
    @link.should == '<a href="/pages" class="current">Pages</a>'    
  end
end