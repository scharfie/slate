require File.dirname(__FILE__) + '/../spec_helper'

describe AreasHelper do
  before(:each) do
    @area = mock(Area)
  end
  
  def version(x)
    @area.stub!(:version).and_return(x)
    @area
  end
  
  it "should return proper panel title for each version" do
    helper.panel_title(version(1)).should == 'Published'
    helper.panel_title(version(2)).should == 'One version ago'
    helper.panel_title(version(3)).should == 'Two versions ago'
    helper.panel_title(version(4)).should == 'Three versions ago'
  end
  
  it "should return timestamp (this year) for area" do
    Time.stub!(:now).and_return(Time.local(2008, 3, 20, 9, 0, 0))
    @area.stub!(:published_at).and_return(Time.local(2008, 9, 7, 9, 0, 0))
    
    helper.version_timestamp(@area).should == '9:00 am on September 7th'
  end
  
  it "should return timestamp (different year) for area" do
    Time.stub!(:now).and_return(Time.local(2007, 3, 20, 9, 0, 0))
    @area.stub!(:published_at).and_return(Time.local(2008, 9, 7, 9, 0, 0))
    
    helper.version_timestamp(@area).should == 'September 7th 2008'
  end  
end
