require File.dirname(__FILE__) + '/../spec_helper'

describe "Slate::Version" do
  it "should return current version as string" do
    expected = "#{Slate::Version::MAJOR}.#{Slate::Version::MINOR}.#{Slate::Version::MACRO}"
    Slate::Version::STRING.should == expected
    Slate::Version.to_s.should == expected
  end
end