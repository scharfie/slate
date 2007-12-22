require 'action_view/helpers/tag_helper'

module ActionView
  module Helpers
    module TagHelper
      alias :rails_tag :tag unless method_defined? :rails_tag
      def tag(name, options = nil, open = false, escape = false)
        # when we have an input field, set the class attribute
        # based on the type attribute
        if name.to_s.downcase =~ /^input$/
          options = HashWithIndifferentAccess.new(options)
          type = options[:type] || 'none'
          unless options[:class] =~ /(^| )#{type}( |$)/
            options[:class] = [options[:class], type].compact.join(' ')
          end  
        end
        
        args = [name, options, open]
        args << escape if method(:rails_tag).arity > 3
        
        rails_tag(*args)
      end            
    end
  end
end  

module ActionView
  module Helpers
    class InstanceTag
      # remove the reference to 
      # the original tag method
      remove_method :tag
    end
  end
end
