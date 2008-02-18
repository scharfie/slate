require File.dirname(__FILE__) + '/../spec_helper'

describe PagesController do
  before(:each) do
    @space = mock(Space)
    @space.stub!(:theme).and_return('theme_support')
    Space.active = @space
    
    request.host = 'slate.local.host'
  end
  
  it "should use PagesController" do
    controller.should be_an_instance_of(PagesController)
  end
  
  it "should assign root object for resource on GET to /index" do
    @root  = mock(Page)
    @space.should_receive(:pages).and_return(Page)
    
    controller.should_receive(:capture_user).and_return(true)
    Space.should_receive(:find).with('77').and_return(@space)
    Page.should_receive(:root).and_return(@root)
    
    get 'index', :space_id => 77
    assigns['page'].should == @root
  end
  
  it "should create a new page with parent 91 on GET to /new/91" do
    @space.should_receive(:pages).and_return(Page)
    
    controller.should_receive(:capture_user).and_return(true)
    Space.should_receive(:find).with('77').and_return(@space)
    
    get 'new', :space_id => 77, :id => 91
    assigns['page'].parent_id.should == 91
  end
  
  it "should invoke 'view_page' on GET to /show" do
    @page = mock(Page)
    controller.should_receive(:capture_user).and_return(true)
    Space.should_receive(:find).with('77').and_return(@space)
    @space.should_receive(:pages).and_return(Page)
    
    Page.should_receive(:find).with('91').and_return(@page)
    controller.should_receive(:view_page)
    
    get 'show', :space_id => 77, :id => 91
    response.should be_success
  end
  
  it "should grab root page on GET to /organize" do
    @root = mock(Page)
    controller.should_receive(:capture_user).and_return(true)
    Space.should_receive(:find).with('77').and_return(@space)
    @space.should_receive(:pages).and_return(Page)
    Page.should_receive(:root).and_return(@root)
    
    get 'organize', :space_id => 77
    controller.resource.should == @root
    response.should be_success
  end
  
  it "should remap tree on PUT to /remap" do
    controller.should_receive(:capture_user).and_return(true)
    Space.should_receive(:find).with('77').and_return(@space)
    @space.should_receive(:pages).and_return(Page)
    
    Page.should_receive(:remap_tree!).with('2-1,3-1,4-1,5-2')
    
    put 'remap', :space_id => 77, :mappings => '2-1,3-1,4-1,5-2'
    flash[:notice].should == 'Successfully re-organized pages!'
    response.should redirect_to(controller.resources_path)
  end
end

describe PagesController do
  before(:each) do
    @space = mock(Space)
    @space.stub!(:theme).and_return('theme_support')
    Space.active = @space

    @page = mock(Page)
    controller.should_receive(:capture_user!)
    
    Space.should_receive(:find).with('77').and_return(@space)
    Page.should_receive(:find).with('91').and_return(@page)

    @space.should_receive(:pages).and_return(Page)
    @space.stub!(:to_param).and_return(77)
    @page.stub!(:to_param).and_return(91)
    
    request.host = 'slate.local.host'
  end
  
  it "should redirect to edit page on GET to /show when template is nil" do
    @space.stub!(:theme).and_return('example_theme')
    @page.stub!(:template).and_return(nil)
    
    get 'show', :space_id => 77, :id => 91
    flash[:error].should_not be_nil
    response.should redirect_to(controller.edit_resource_url)
  end
  
  it "should redirect to edit space on GET to /show when theme is nil" do
    @space.stub!(:theme).and_return(nil)
    
    get 'show', :space_id => 77, :id => 91
    flash[:error].should_not be_nil
    response.should redirect_to(controller.edit_enclosing_resource_url)
  end
end