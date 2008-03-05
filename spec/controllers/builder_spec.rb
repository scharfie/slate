require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :BuilderTestController) rescue
Object.send(:remove_const, :BlogsHelper) rescue

class BuilderTestController < ActionController::Base
  include Slate::Builder
  
  def show
    @space = Space.find(133)
    @page  = Page.find(91)  
    view_page
  end
  
  def invoke_content_for_header
    @space = Space.find(133)
    @page  = Page.find(91)  
    content_for(:header)
  end
end

module BlogsHelper
  def blogs_helper_method
    
  end
end

describe 'Slate::Builder' do
  controller_name 'BuilderTest'
  
  before(:each) do
    controller.request = request
    
    @space = mock(Space)
    @page = mock(Page)
    @space.stub!(:theme).and_return('portfolio')
    @page.stub!(:template).and_return('home')
    @page.stub!(:behavior).and_return(nil)
    
    Space.stub!(:find).and_return(@space)
    Page.stub!(:find).and_return(@page)
  end
  
  after(:each) do
    ActionController::Routing::Routes.reload
  end
  
  it "should render public theme template portfolio/home" do
    get :show
    template = 'portfolio/home'
    response.should render_template(template)
  end
  
  it "should render builder/area partial for content_for(:header)" do
    @area = mock(Area)
    @area.should_receive(:new_record?).and_return(false)
    @page.should_receive(:content_for).with(:header, :draft).and_return(@area)
    
    get :invoke_content_for_header
    response.should render_template('builder/_area')
  end
  
  it "should load behavior 'Blog'" do
    @blog = mock('Blog')
    @blog.stub!(:class).and_return('Blog')
    @page.stub!(:behavior).and_return(@blog)
    
    get :show
    response.template.should respond_to(:blogs_helper_method)
    response.should render_template('portfolio/home')
    assigns[:blog].should == @blog
  end
  
  it "should not load behavior helper due to missing helper" do
    @blog = mock('Blog')
    @blog.stub!(:class).and_return('MyBlog')
    @page.should_receive(:behavior).and_return(@blog)
    controller.instance_variable_set(:@page, @page)
    
    controller.send(:load_behavior_helper).should == nil
  end
end

describe 'Slate::Builder with integrated views' do
  controller_name 'BuilderTest'
  integrate_views

  before(:each) do
    @space = mock(Space)
    @page = mock(Page)
    @space.stub!(:theme).and_return('portfolio')
    @page.stub!(:template).and_return('home')
    @page.stub!(:behavior).and_return(nil)
    
    Space.stub!(:find).and_return(@space)
    Page.stub!(:find).and_return(@page)
  end
  
  it "should raise Slate::TemplateMissing when template cannot be found" do
    get_show = lambda { get :show }
    get_show.should raise_error(Slate::TemplateMissing)
  end
end
  
describe 'Slate::Builder' do
  controller_name 'BuilderTest'
  
  before(:each) do
    controller.params = HashWithIndifferentAccess.new
  end
  
  it "should be in editor mode" do
    controller.should_not be_production
    controller.should_not be_preview
    controller.should be_editor
  end
  
  it "should be in production mode when params[:mode] == 'production'" do
    controller.params[:mode] = 'production'
    controller.should be_production
    controller.should_not be_preview
    controller.should_not be_editor
  end

  it "should be in preview mode when params[:mode] == 'preview'" do
    controller.params[:mode] = 'preview'
    controller.should_not be_production
    controller.should be_preview
    controller.should_not be_editor
  end
end