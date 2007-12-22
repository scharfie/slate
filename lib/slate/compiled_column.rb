module Slate
  module CompiledColumn
    def self.included(base)
      base.extend ClassMethods
    end
    
    # compiles the given text using specified
    # compiler (defaulting to RedCloth)
    def self.compile(text, options={})
      compiler = options.delete(:compiler) || RedCloth
      compiler.new(text || '', options).to_html
    end
    
    module ClassMethods
      # creates a new compiled column from given
      # column name - the compiled column name will
      # be "[name]_html".  A before_save callback is
      # created which ensures that the compiled column
      # is updated on each save. 
      def compiled_column(name, options={})
        compiled_name = "#{name}_html"
        
        # creates new method for compiled name
        # which will return the compiled content
        define_method compiled_name do
          self[compiled_name] = Slate::CompiledColumn.compile(self[name], options)
        end
        
        before_save do |record|
          record.send(compiled_name)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Slate::CompiledColumn