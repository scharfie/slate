require File.dirname(__FILE__) + '/../spec_helper'

describe Plugin do
  before(:each) do
    @plugin = Plugin.new
  end

  it "should be valid" do
    @plugin.should be_valid
  end
end
