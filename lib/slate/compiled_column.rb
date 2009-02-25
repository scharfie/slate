module Slate
  module CompiledColumn
    class TextileCompiler
      def self.process(text, options={})
        ::RedCloth.new(text || '', options).to_html
      end
    end
    
    class MarkdownCompiler
      def self.process(text, options={})
        ::BlueCloth.new(text || '', options).to_html
      end
    end
    
    class HtmlCompiler
      def self.process(text, options={})
        text
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end
    
    def self.compiler_for_format(format)
      self.const_get(format.classify + 'Compiler')
    end
    
    # compiles the given text using specified
    # compiler (defaulting to RedCloth)
    def self.compile(text, options={})
      format   = (options.delete(:format) || 'textile')
      compiler = compiler_for_format(format.to_s.downcase)
      compiler.process(text, options)
    end
    
    def self.compilers
      returning ActiveSupport::OrderedHash.new do |hash|
        hash['Textile']  = 'textile'
        hash['HTML']     = 'html'
      end
    end
    
    module InstanceMethods
      def format
        self[:format] || 'textile'
      end      
      
      def compile_field(field, options={})
        options.reverse_merge! :format => self.format
        Slate::CompiledColumn.compile(self[field], options)
      end
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
          self[compiled_name] = compile_field(name)
        end
        
        before_save do |record|
          record.send(compiled_name)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Slate::CompiledColumn