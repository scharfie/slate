require File.dirname(__FILE__) + '/../spec_helper'

describe "Slate::Version" do
  it "should return current version as string" do
    Slate::Version::STRING.should == 
      "#{Slate::Version::MAJOR}.#{Slate::Version::MINOR}.#{Slate::Version::MACRO}"
  end
  
  it "should return version with revision from Slate:Version.to_s" do
    Slate::Version.to_s == 
      "#{Slate::Version::MAJOR}.#{Slate::Version::MINOR}.#{Slate::Version::MACRO} r#{Slate::Version::REVISION}"
  end
end