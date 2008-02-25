require File.dirname(__FILE__) + '/../spec_helper'

describe DashboardHelper do
  it "should include the DashboardHelper" do
    included_modules = self.class.send :included_modules
    included_modules.should include(DashboardHelper)
  end
end
