module RPH
  module FormAssistant
    private
      # The Collector class gathers (or "collects") all
      # of the components needed to build the output
      class Collector
        attr_accessor :collection
      
      private
        # adds an item to the collection
        # (returns self so it can keep collecting)
        def collect(item)
          collection << item and return self
        end
      
      public
        # convenience method to start off the collection
        def self.wrap(element)
          new.send(:collect, element.to_sym)
        end
        
        # new collection
        def initialize
          @collection = []
        end
        
        # used to collect the element attributes
        def having(attrs = {})
          collect(attrs)
        end
        
        # used to collect the content that will be wrapped
        def around(content)
          collect(content)
        end
        
        # hands the collection over to the Builder to be built
        def for(template, binding = nil)
          Builder.build(collection).for(template, binding)
        end
      end
  end
end