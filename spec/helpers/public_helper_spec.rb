require File.dirname(__FILE__) + '/../spec_helper'

describe PublicHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should include the PublicHelper" do
    included_modules = self.class.send :included_modules
    included_modules.should include(PublicHelper)
  end
  
end
