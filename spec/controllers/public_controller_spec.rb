require File.dirname(__FILE__) + '/../spec_helper'

describe PublicController do
  before(:each) do
    request.host = 'slate.example.com'
    @space = mock(Space)
    @page  = mock(Page)
  end
  
  it "should find space for domain 'slate.example.com' on GET to /index" do
    Page.should_receive(:find_by_page_path).and_return(nil)  
    Space.should_receive(:find_by_domain).with('slate.example.com').
      and_return(@space)
    
    @space.should_receive(:pages).and_return(Page)
    @space.should_receive(:default_page).and_return(@page)
    
    controller.should_receive(:prepend_theme_view_paths).and_return(true)
    controller.should_receive(:view_page)
      
    get 'index', :page_path => ['/']
    response.should be_success
  end
end
