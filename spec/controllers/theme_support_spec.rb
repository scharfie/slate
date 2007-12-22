require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :ThemeSupportTestController) rescue

class ThemeSupportTestController < ActionController::Base
  include Slate::ThemeSupport
  
  def show
  end
end

describe 'Slate::ThemeSuport' do
  controller_name 'ThemeSupportTest'
  
  before(:each) do
    @space = mock(Space)
    @space.stub!(:theme).and_return('theme_support')
    Space.stub!(:active).and_return(@space)
  end
  
  it "should add view path for 'theme_support' theme" do
    get 'show'
    view_paths = controller.view_paths
    view_paths.should have(2).items
    view_paths.first.should include('public/themes/theme_support/views')
  end
  
  it "should return theme view path for 'theme_support' theme" do
    path = controller.theme_view_path
    path.should include('public/themes/theme_support/views')
  end
  
  it "should not add view path when no Space is active" do
    Space.stub!(:active).and_return(nil)
    get 'show'
    view_paths = controller.view_paths
    view_paths.should have(1).items
  end 
end

describe 'Slate::ThemeSuport with integrated views' do
  controller_name 'ThemeSupportTest'
  integrate_views
  
  before(:each) do
    @space = mock(Space)
    @space.stub!(:theme).and_return('theme_support')
    Space.stub!(:active).and_return(@space)
  end

  it "should render theme template for 'show'" do
    path = File.expand_path(
      File.join(File.dirname(__FILE__), '../public/themes/example_theme/views'))
    controller.stub!(:theme_view_path).and_return(path)
    
    # # manually call the before_filter here because of the
    # # way integrate_views works
    # controller.add_theme_view_path
    
    get 'show'
    
    response.should render_template('theme_support_test/show')
    response.body.should include('Themed view')
    response.body.should include(path)
  end
end