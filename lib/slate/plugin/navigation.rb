module Slate
  class Plugin
    class Navigation
      attr_accessor :items
      attr_accessor :controller
      
      # Creates a new Navigation builder
      def initialize(controller)
        @controller = controller
      end
    
      # Adds item to the navigation items collection
      def add(name=nil, options={})
        (@items ||= []) << [name, options]
      end
      
      def []=(key, value)
        add(key, value)
      end
      
      # Returns items or empty array
      def items
        @items || []
      end
      
      # Pass all other method calls to the controller
      # (for named routes, etc.)
      def method_missing(m, *args, &block)
        controller.send(m, *args, &block)
      end
    end
  end
end