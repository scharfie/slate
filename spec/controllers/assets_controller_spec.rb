require File.dirname(__FILE__) + '/../spec_helper'

describe AssetsController do
  before(:each) do
    controller.stub!(:capture_user!)
    controller.stub!(:capture_space!)

    @space = mock(Space)
    @space.stub!(:to_param).and_return(1)
  end
  
  it "should extract ZIP file on GET to /extract" do
    @asset = mock(Asset)
    @space.should_receive(:assets).and_return(Asset)
    Space.should_receive(:find).with('1').and_return(@space)
    Asset.should_receive(:find).with('56').and_return(@asset)
    @asset.should_receive(:extract!).and_return([1,2,3])
    
    get :extract, :space_id => 1, :id => 56
    response.should redirect_to(space_assets_url(1))
  end
end