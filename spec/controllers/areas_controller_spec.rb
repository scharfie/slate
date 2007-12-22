require File.dirname(__FILE__) + '/../spec_helper'

describe AreasController do
  before(:each) do
    controller.stub!(:capture_user!)
    controller.stub!(:capture_space!)
    
    @space = mock(Space)
    @page = mock(Page)
    @area = mock(Area)
    
    Space.stub!(:find).and_return(@space)
    Page.stub!(:find).and_return(@page)
    
    @space.stub!(:to_param).and_return(37)
    @page.stub!(:to_param).and_return(50)
    
    @space.should_receive(:pages).and_return(Page)
    @page.should_receive(:areas).and_return(Area)
  end
  
  it "should find area by key with id 'header' on GET to /edit" do
    Area.should_receive(:find_by_key).with('header').and_return(@area)

    get :edit, :id => 'header', :space_id => 37, :page_id => 50
    response.should render_template('edit')
  end

  it "should build area 'main' on POST to /create" do
    Area.should_receive(:find_by_key).with('main').and_return(nil)
    Area.should_receive(:build).with(:key => 'main').and_return(@area)
    
    @area.should_receive(:update_attributes)
    post :create, :key => 'main', :space_id => 37, :page_id => 50
    response.should render_template('edit')
  end

  
  it "should update area 'sidebar' on PUT to /update" do
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    
    @area.should_receive(:update_attributes)
    put :update, :id => 'sidebar', :space_id => 37, :page_id => 50
    response.should render_template('edit')
  end
  
  it "should publish area 'sidebar with commit param 'Publish' on PUT to /update" do
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    
    @area.should_receive(:update_attributes)
    @area.should_receive(:publish!)
    
    put :update, :id => 'sidebar', :space_id => 37, 
      :page_id => 50, :commit => 'Publish'
    response.should render_template('edit')
  end
  
  it "should toggle area 'sidebar' and redirect to page on GET to /toggle" do
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    @area.should_receive(:new_record?).and_return(false)
    @area.should_receive(:toggle!).with(no_args)
    
    get :toggle, :id => 'sidebar', :space_id => 37, :page_id => 50
    response.should redirect_to(space_page_url(37, 50))
  end
  
  it "should destroy area 'sidebar' and redirect to page on DELETE to /destroy" do
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    @area.should_receive(:destroy).with(no_args)
    
    delete :destroy, :id => 'sidebar', :space_id => 37, :page_id => 50
    response.should redirect_to(space_page_url(37, 50))
  end
  
  it "should retrieve version 1 of area 'sidebar' on GET to /version" do
    @area_version_1 = mock(Area)
    
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    Area.should_receive(:find_by_version).with('1').and_return(@area_version_1)
    @area.should_receive(:versions).and_return(Area)
    
    get :version, :id => 'sidebar', :space_id => 37, :page_id => 50, :version => 1
    response.should render_template('version')
  end  
  
  it "should preview area 'sidebar' on POST to /preview" do
    Area.should_receive(:find_by_key).with('sidebar').and_return(@area)
    
    @area.should_receive(:attributes=)
    
    # NOTE: this test is likely incorrect as I don't know how
    # to make RSpec test respond_to blocks yet
    post :preview, :format => 'js', :id => 'sidebar', 
      :space_id => 37, :page_id => 50
    response.should render_template('preview')
  end
end