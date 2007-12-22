require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsHelper do
  include ApplicationHelper
  
  it "should return preview image for image asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(true)
    @asset.should_receive(:public_filename).with('sq').and_return('/assets/test_sq.png')
    
    tag = asset_image_tag(@asset, 'sq')
    tag.should include('/assets/test_sq.png')
  end
  
  it "should return glyph for text asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(false)
    
    tag = asset_image_tag(@asset, 'sq')
    tag.should include('/images/glyphs/page_white.png')
  end
  
  it "should render partial 'image' for image asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(true)
    
    should_receive(:render).with(:partial => 'image', :object => @asset)
    asset_view(@asset)
  end
  
  it "should render partial 'zip' for ZIP asset" do
    @asset = mock(Asset)
    @asset.should_receive(:image?).and_return(false)
    @asset.should_receive(:zip?).and_return(true)
    
    should_receive(:render).with(:partial => 'zip', :object => @asset)
    asset_view(@asset)
  end  
end