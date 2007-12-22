require File.dirname(__FILE__) + '/../spec_helper'

class MySlateError < Slate::Error
end  

describe Slate::Error do
  before(:each) do
    @message = "Default error message for MySlateError"
    @custom_message = "Custom error message for MySlateError (passed as argument)"
    
    MySlateError.message = @message
  end
  
  def my_slate_error
    lambda { raise MySlateError }
  end
  
  def my_slate_error_with_custom_message
    lambda { raise MySlateError, @custom_message }
  end
  
  it "should set default message" do
    MySlateError.message.should == @message
    MySlateError.new.message.should == @message
  end
  
  it "should raise default message" do
    MySlateError.message = @message
    my_slate_error.should raise_error(MySlateError, @message)    
  end
  
  it "should raise custom message when provided" do
    my_slate_error_with_custom_message.should raise_error(MySlateError, @custom_message)
  end
end