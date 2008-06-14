require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsHelper do
  include ApplicationHelper
  
  it "should return preview image for image asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(true)
    @asset.should_receive(:public_filename).with('sq').and_return('/assets/test_sq.png')
    
    tag = helper.asset_image_tag(@asset, 'sq')
    tag.should include('/assets/test_sq.png')
  end
  
  it "should return glyph for text asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(false)
    
    helper.should_receive(:glyph).with('page_white')
    helper.asset_image_tag(@asset, 'sq')
  end
  
  it "should render partial 'image' for image asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(true)
    
    helper.should_receive(:render).with(:partial => 'image', :object => @asset)
    helper.asset_view(@asset)
  end
  
  it "should render partial 'zip' for ZIP asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(false)
    @asset.should_receive(:zip?).and_return(true)
    
    helper.should_receive(:render).with(:partial => 'zip', :object => @asset)
    helper.asset_view(@asset)
  end  
end