require File.join(File.dirname(__FILE__), 'spec_helper')

class Basic < MockAR::Base
  acts_as_lookup :title
end

class Customized < MockAR::Base
  acts_as_lookup :title, :default_text => '-- Choose --', :conditions => 'id <> 3', :order => 'id DESC'
end

class DefaultToFirstOption < MockAR::Base
  acts_as_lookup :title, :default_text => :first
end

describe "ActsAsLookup" do
  E = RPH::ActsAsLookup::Error
  
  before(:each) do
    @basic = Basic
  end
  
  describe "Models" do
    it "should respond to `acts_as_lookup'" do
      @basic.should respond_to(:acts_as_lookup)
    end
  
    it "should respond to `options_for_select'" do
      @basic.should respond_to(:options_for_select)
    end
    
    it "should have 4 items in the array" do
      @basic.options_for_select.size.should eql(4)
    end
    
    it "should respond to `field_to_select'" do
      @basic.should respond_to(:field_to_select)
    end
    
    it "should have field_to_select set to 'title'" do
      @basic.field_to_select.should eql(:title)
    end
    
    describe "default options" do
      it "should have no conditions by default" do
        @basic.options[:conditions].should be_nil
      end
      
      it "should have default text of '--' for first select item" do
        @basic.options[:default_text].should_not be_nil
        @basic.options[:default_text].should eql('--')
      end
    
      it "should have default order of field_to_select (for alphabetical list)" do
        @basic.options[:order].should_not be_nil
        @basic.options[:order].should eql(@basic.field_to_select.to_s)
      end
    end
    
    describe "customization" do      
      before(:each) do
        @customized = Customized
      end
      
      it "should support custom text for the first select entry" do
        @customized.options_for_select.first[0].should eql('-- Choose --')
      end
    
      it "should support custom conditions for SQL" do
        @customized.options[:conditions].should_not be_nil
        @customized.options[:conditions].should eql('id <> 3')
      end
    
      it "should support custom order for SQL" do
        @customized.options[:order].should_not be_nil
        @customized.options[:order].should eql('id DESC')
      end
      
      it "should not add the default 'nil' option if :default_text set to :first" do
        DefaultToFirstOption.options_for_select.size.should eql(3)
      end
    end
  end
  
  describe "Views" do
    include ActionView::Helpers::FormOptionsHelper
    
    it "should respond to `lookup_for' as a helper" do
      ActionView::Base.new.should respond_to(:lookup_for)
    end
    
    it "should respond to `lookup_for' from a FormBuilder" do
      ActionView::Helpers::FormBuilder.new(nil, nil, nil, nil, nil).should respond_to(:lookup_for)
    end
    
    it "`lookup_for' should act the same as regular select" do
      ActionView::Base.new.lookup_for(:other, :basic_id).
        should eql(select(:other, :basic_id, Basic.options_for_select))
    end
  end
  
  describe "Errors" do
    it "should raise InvalidAttr if attr passed to `acts_as_lookup' does not exist" do
      TestModel.acts_as_lookup(:wrong) rescue E::InvalidAttr
    end
    
    it "should raise InvalidLookup if model passed to `lookup_for' does not have `acts_as_lookup'" do
      ActionView::Base.new.lookup_for(:wrong) rescue E::InvalidLookup
    end
    
    it "should raise InvalidModel if model passed to `lookup_for' does not exist" do
      class InvalidModel; self; end
      
      ActionView::Base.new.lookup_for(:invalid_model) rescue E::InvalidModel
    end
  end
end