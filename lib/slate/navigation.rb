module Slate
  module Navigation
    module ClassMethods
      attr_accessor :current_tab
      
      # Returns the current tab (defaulting to tab based on
      # current controller)
      # 
      # Optionally, a value may be passed in to set the tab.
      # This provides a slightly friendlier syntax in a controller:
      # 
      #   class SomeController < ApplicationController
      #     current_tab 'My tab'
      #   end
      def current_tab(value=nil)
        @current_tab = value if value
        @current_tab ||= self.to_s.sub('Controller', '')
      end
    end
    
    module InstanceMethods
      # Helper method that returns the current tab
      def current_tab
        self.class.current_tab
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :helper_method, :current_tab
    end
  end
end