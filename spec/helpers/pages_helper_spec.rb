require File.dirname(__FILE__) + '/../spec_helper'

describe PagesHelper do
  before(:each) do
    @page = mock(Page)
    @page.stub!(:default?).and_return(false)        
  end
  
  it "should return proper glyph for normal page" do
    helper.should_receive(:glyph).with('page_white')
    helper.page_glyph(@page)
  end
  
  it "should return proper glyph for default page" do
    helper.should_receive(:glyph).with('house')
    @page.should_receive(:default?).and_return(true)
    helper.page_glyph(@page)
  end
end
