require File.dirname(__FILE__) + '/../spec_helper'

Object.send(:remove_const, :BuilderTestController) rescue

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

describe 'Slate::Builder' do
  controller_name 'BuilderTest'
  
  before(:each) do
    @space = mock(Space)
    @page = mock(Space)
    @space.stub!(:theme).and_return('portfolio')
    @page.stub!(:template).and_return('home')
    
    Space.stub!(:find).and_return(@space)
    Page.stub!(:find).and_return(@page)
  end
  
  it "should render public theme template portfolio/home" do
    get :show
    template = File.join(Slate::Builder::THEME_TEMPLATE_ROOT, 'portfolio/home')
    response.should render_template(template)
  end
  
  it "should render builder/area partial for content_for(:header)" do
    @area = mock(Area)
    @area.should_receive(:new_record?).and_return(false)
    @page.should_receive(:content_for).with(:header, :draft).and_return(@area)
    
    get :invoke_content_for_header
    response.should render_template('builder/_area')
  end
end

describe 'Slate::Builder with integrated views' do
  controller_name 'BuilderTest'
  integrate_views

  before(:each) do
    @space = mock(Space)
    @page = mock(Space)
    @space.stub!(:theme).and_return('portfolio')
    @page.stub!(:template).and_return('home')
    
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