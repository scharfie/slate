require File.dirname(__FILE__) + '/../spec_helper'

describe BuilderHelper, '(Base)' do
  before(:each) do
    helper.class.send :include, ApplicationHelper
    helper.class.send :include, Slate::Builder::Helpers

    helper.stub!(:params).and_return({})
  end  
  
  def mock_theme(name='my_theme')
    @space = mock(Space)
    @space.stub!(:theme).and_return(name)
    
    assigns[:space] = @space
  end
  
  it "should include necessary support files" do
    helper.should_receive(:slate?).and_return(true)
    @files = helper.support_files
    @files.should include('/stylesheets/builder.css')
    @files.should include('/javascripts/jquery.js')
    @files.should include('/javascripts/slate/builder.js')
  end
  
  it "should render support toolbar" do
    helper.should_receive(:slate?).and_return(true)
    helper.should_receive(:render).with(:partial => 'builder/support_toolbar')
    helper.support_toolbar
  end
  
  it "should return '/themes/my_theme' for theme_path" do
    mock_theme 'my_theme'
    helper.theme_path.should == '/themes/my_theme'
  end
  
  it "should have qualified theme path 'my_theme/header' for 'header'" do
    mock_theme 'my_theme'
    helper.qualified_theme_path('header').should == 'my_theme/header'
  end
  
  it "should have qualified theme path 'shared/header' for 'shared/header'" do
    mock_theme 'my_theme'
    helper.qualified_theme_path('shared/header').should == 'shared/header'
  end
  
  it "should render 'some_theme/footer' for partial(:footer)" do
    mock_theme 'some_theme'
    helper.should_receive(:render).with(:partial => 'some_theme/footer')
    helper.partial :footer
  end
end

describe BuilderHelper, '(Admin)' do
  before(:each) do
    helper.class.send :include, ApplicationHelper
    stub!(:params).and_return({})
    
    @space = mock(Space)
    @space.stub!(:id).and_return(55)

    @page = mock(Page)
    @page.stub!(:id).and_return(123)
    
    @area = mock(Area)
    @area.stub!(:new_record?).and_return(false)
    @area.stub!(:default?).and_return(false)
    @area.stub!(:using_default?).and_return(false)
    
    assigns[:space] = @space
    assigns[:page]  = @page
    assigns[:area]  = @area
    assigns[:controller] = self
  end

  it "should create an edit link to area 'footer'" do
    @area.stub!(:key).and_return('footer')
    @link = helper.edit_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/footer')
  end
  
  it "should create a link to toggle default area 'contact'" do
    @area.stub!(:key).and_return('contact')
    @link = helper.toggle_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/contact/toggle')
  end
  
  it "should create a link to clear area 'authors'" do
    @area.stub!(:key).and_return('authors')
    @link = helper.clear_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/authors')
    @link.should include('delete')
  end
  
  it "should return proper CSS class for default area on current page" do
    @area.stub!(:default?).and_return(true)
    @area.stub!(:using_default?).and_return(false)
    @area.stub!(:page).and_return(@page)
    @class = helper.area_class(@area)
    @class.should == 'b-default'
  end

  it "should return proper CSS class for default area on different page" do
    @different_page = mock(Page)
    @area.should_receive(:default?).with(no_args).and_return(true)
    @area.should_receive(:default?).with(@page).and_return(false)
    @class = helper.area_class(@area)
    @class.should == 'b-u-default'
  end
end