module RPH
  module FormAssistant
    # class used to DRY up error handling
    class Error < RuntimeError
      def self.message(msg=nil)
        msg.nil? ? @message : self.message = msg 
      end
      
      def self.message=(msg)
        @message = msg 
      end
    end
    
    # custom errors go here
  end
end