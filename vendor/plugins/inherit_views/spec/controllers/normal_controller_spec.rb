require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe NormalController do
  integrate_views

  it "GET :partial_from_c should render normal/partial_from_c, then c/_partial_in_bc" do
    get :partial_from_c
    response.body.should == 'normal:partial_from_c => c:_partial_in_bc'
  end
end