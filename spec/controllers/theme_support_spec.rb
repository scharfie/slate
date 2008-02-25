require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :ThemeSupportTestController) rescue

class ThemeSupportTestController < ActionController::Base
  include Slate::ThemeSupport
  
  attr_accessor :template
  
  def initialize
    super
    @template = ::ActionView::Base.new
    @template.finder.view_paths = self.class.view_paths
    @assigns = {}
  end  
  
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
    view_paths.should have(3).items
    view_paths[0].should include('public/themes')
    view_paths[1].should include('public/themes/theme_support/views')
  end
  
  it "should return themes path" do
    path = controller.send :themes_view_path
    path.should include('public/themes')
  end
  
  it "should return theme view path for 'theme_support' theme" do
    path = controller.send :theme_views_path
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
    @space.stub!(:theme).and_return('example_theme')
    Space.stub!(:active).and_return(@space)
  end

  it "should render theme template for 'show'" do
    path = App.root / 'spec/public/themes/example_theme/views'
    controller.stub!(:theme_views_path).and_return(path)
    
    get 'show'
    
    response.should render_template('theme_support_test/show')
    response.body.should include('Themed view')
    response.body.should include(path)
  end
end