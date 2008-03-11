require File.dirname(__FILE__) + '/../spec_helper'

describe PublicController do
  before(:each) do
    request.host = 'slate.example.com'
    @space = mock(Space)
    @page  = mock(Page)

    Space.should_receive(:find_by_domain).with('slate.example.com').
      and_return(@space)

    controller.should_receive(:prepend_theme_view_paths).and_return(true)
  end
  
  it "should return default page on 'slate.example.com' (with no page path)" do
    @space.should_receive(:default_page).and_return(@page)
    @page.should_receive(:url).and_return('some/page/path')
    controller.should_receive(:view_page)
      
    get 'index', :page_path => nil
    response.should be_success
    params[:page_path].should == 'some/page/path'
  end

  it "should return specific page on 'slate.example.com/home/demo'" do
    @space.should_receive(:pages).and_return(Page)
    Page.should_receive(:find_by_page_path).with(%w(home demo)).and_return(@page)
    controller.should_receive(:view_page)
    
    get 'index', :page_path => 'home/demo'.split('/')
    response.should be_success
  end
  
  it "should raise error on invalid page path 'slate.example.com/invalid/path'" do
    @space.should_receive(:pages).and_return(Page)
    Page.should_receive(:find_by_page_path).with(%w(invalid path)).and_return(nil)

    lambda { get('index', :page_path => %w(invalid path)) }.
      should raise_error("No page found")
  end
end
