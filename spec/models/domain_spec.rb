require File.dirname(__FILE__) + '/../spec_helper'

describe Domain do
  before(:each) do
    @domain = Domain.new
  end

  it "should be valid" do
    @domain.should be_valid
  end
end
