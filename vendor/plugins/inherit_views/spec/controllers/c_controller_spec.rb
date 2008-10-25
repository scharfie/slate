require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe CController, " < BController" do
  describe "(the class)" do
    it { CController.should be_inherit_views }

    it "should have inherit view paths == ['c', 'b', 'a']" do
      CController.inherit_view_paths.should == ['c', 'b', 'a']
    end
  end

  describe "(an instance)" do
    integrate_views
  
    it { @controller.should be_inherit_views }

    it "should have inherit view paths == ['c', 'b', 'a']" do
      @controller.inherit_view_paths.should == ['c', 'b', 'a']
    end
  
    it "GET :in_a should render a/in_a" do
      get :in_a
      response.body.should == 'a:in_a'
    end
  
    it "GET :in_ab should render b/in_ab" do
      get :in_ab
      response.body.should == 'b:in_ab'
    end
  
    it "GET :in_b should render b/in_b" do
      get :in_b
      response.body.should == 'b:in_b'
    end

    it "GET :in_abc should render c/in_abc" do
      get :in_abc
      response.body.should == 'c:in_abc'
    end
  
    it "GET :in_c should render c/in_c" do
      get :in_c
      response.body.should == 'c:in_c'
    end
  
    it "GET :partial_in_bc should render b/partial_in_bc then c/_partial_in_bc" do
      get :partial_in_bc
      response.body.should == "b:partial_in_bc => c:_partial_in_bc"
    end
  
    it "GET :partial_in_b should render b/partial_in_b & b/_partial_in_b" do
      get :partial_in_b
      response.body.should == "b:partial_in_b => b:_partial_in_b"
    end
    
    it "GET :collection_in_bc should render b/collection_in_bc then c/_partial_in_bc" do
      get :collection_in_bc
      response.body.should == 'b:collection_in_bc => c:_partial_in_bc'
    end
  end
end