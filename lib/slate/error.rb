module Slate
  # Slate::Error is a custom exception base class.  
  # All slate errors should descend from this base class.
  # 
  # This class defines a custom default message feature
  # for DRY exception messages.
  # 
  # Example:
  # (normal)
  #   class MyError < StandardError; end
  #   raise MyError rescue $!.message
  #   # => MyError
  # (Slate::Error)
  #   class MySlateError < Slate::Error; message "Custom error"; end
  #   raise MyError rescue $!.message
  #   # => Custom error
  class Error < StandardError
    class << self
      @message = nil
      
      # sets/gets the default message for this class
      # (the message is simply retrieved when the argument is nil)
      def message(msg=nil)
        msg.nil? ? @message : self.message = msg
      end
      
      # sets the default message
      def message=(msg)
        @message = msg
      end
    end
    
    # override the default initializer for errors
    # to set the message to default if necessary
    def initialize(message=nil)
      @message = message || self.class.message
    end
    
    # returns the message for this exception
    # (defaulting to super)
    def message
      @message || super
    end
  end
end