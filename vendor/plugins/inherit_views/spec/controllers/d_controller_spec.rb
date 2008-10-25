require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe DController, " < AController; inherit_views 'other'" do
  describe "(the class)" do
    it { DController.should be_inherit_views }

    it "should have inherit view paths == ['d', 'other', 'a']" do
      DController.inherit_view_paths.should == ['d', 'other', 'a']
    end
  end
  
  describe "(an instance)" do
    integrate_views
  
    it { @controller.should be_inherit_views }

    it "should have inherit view paths == ['d', 'other', 'a']" do
      @controller.class.inherit_view_paths.should == ['d', 'other', 'a']
    end
  end
end