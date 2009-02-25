require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe BController, " < TestController; inherit_views 'a'" do
  describe "(the class)" do
    it { BController.should be_inherit_views }

    it "should have inherit view paths == ['b', 'a']" do
      BController.inherit_view_paths.should == ['b', 'a']
    end
  end
  
  describe "(an instance)" do
    integrate_views
  
    it { @controller.should be_inherit_views }

    it "should have inherit view paths == ['b', 'a']" do
      @controller.inherit_view_paths.should == ['b', 'a']
    end
  
    it "GET :in_first should render a/in_a" do
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

    it "GET :in_abc should render b/in_abc" do
      get :in_abc
      response.body.should == 'b:in_abc'
    end
  
    it "GET :partial_in_bc should render b/partial_in_bc & b/_partial_in_bc" do
      get :partial_in_bc
      response.body.should == "b:partial_in_bc => b:_partial_in_bc"
    end
  
    it "GET :partial_in_b should render b/partial_in_b & b/_partial_in_b" do
      get :partial_in_b
      response.body.should == "b:partial_in_b => b:_partial_in_b"
    end
    
    it "GET :collection_in_bc should render b/collection_in_bc then b/_partial_in_bc" do
      get :collection_in_bc
      response.body.should == 'b:collection_in_bc => b:_partial_in_bc'
    end
    
    it "GET :render_parent should render a/render_parent inside b/render_parent" do
      get :render_parent
      response.body.should == "b:render_parent(a:render_parent)"
    end

    it "GET :partial_render_parent should render a/_partial_render_parent inside b/_partial_render_parent" do
      get :partial_render_parent
      response.body.should == "b:partial_render_parent => b:_partial_render_parent(a:_parent_render_parent)"
    end
    
    it "GET :bad_render_parent should rasie TemplateError" do
      lambda { get :bad_render_parent }.should raise_error(ActionView::TemplateError)
    end
  end
end