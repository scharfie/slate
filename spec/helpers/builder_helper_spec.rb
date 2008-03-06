require File.dirname(__FILE__) + '/../spec_helper'

describe BuilderHelper, '(Base)' do
  include Slate::Builder::Helpers
  
  it "should include necessary support files" do
    should_receive(:slate?).and_return(true)
    @files = support_files
    @files.should include('/stylesheets/builder.css')
    @files.should include('/javascripts/jquery.js')
    @files.should include('/javascripts/slate/builder.js')
  end
  
  it "should render support toolbar" do
    should_receive(:slate?).and_return(true)
    should_receive(:render).with(:partial => 'builder/support_toolbar')
    support_toolbar
  end
  
  it "should return '/themes/my_theme' for theme_path" do
    @space = mock(Space)
    @space.should_receive(:theme).and_return('my_theme')
    
    theme_path.should == '/themes/my_theme'
  end
end

describe BuilderHelper, '(Admin)' do
  include ApplicationHelper

  before(:each) do
    @space = mock(Space)
    @space.stub!(:id).and_return(55)

    @page = mock(Page)
    @page.stub!(:id).and_return(123)
    
    @area = mock(Area)
    @area.stub!(:new_record?).and_return(false)
    @area.stub!(:default?).and_return(false)
    @area.stub!(:using_default?).and_return(false)
  end

  it "should create an edit link to area 'footer'" do
    @area.stub!(:key).and_return('footer')
    @link = edit_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/footer')
  end
  
  it "should create a link to toggle default area 'contact'" do
    @area.stub!(:key).and_return('contact')
    @link = toggle_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/contact/toggle')
  end
  
  it "should create a link to clear area 'authors'" do
    @area.stub!(:key).and_return('authors')
    @link = clear_area_link(@area)
    @link.should include('/spaces/55/pages/123/areas/authors')
    @link.should include('delete')
  end
  
  it "should return proper CSS class for default area on current page" do
    @area.stub!(:default?).and_return(true)
    @area.stub!(:using_default?).and_return(false)
    @area.stub!(:page).and_return(@page)
    @class = area_class(@area)
    @class.should == 'b-default'
  end

  it "should return proper CSS class for default area on different page" do
    @different_page = mock(Page)
    @area.should_receive(:default?).with(no_args).and_return(true)
    @area.should_receive(:default?).with(@page).and_return(false)
    @class = area_class(@area)
    @class.should == 'b-u-default'
  end
end