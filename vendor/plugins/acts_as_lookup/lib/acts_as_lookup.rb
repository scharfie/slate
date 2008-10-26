module RPH
  module ActsAsLookup
    def self.included(base)
      base.extend ActMethods
    end
    
    module ActMethods
      # Example
      #   class Category < ActiveRecord::Base
      #     acts_as_lookup :title
      #   end
      def acts_as_lookup(field_to_select, optionz={})
        raise(Error::InvalidAttr, Error::InvalidAttr.message) unless self.new.respond_to?(field_to_select)
        
        options = {
          :default_text => '--',
          :order => "#{field_to_select.to_s}"
        }.merge!(optionz)
      
        class_inheritable_accessor :options, :field_to_select
        extend ClassMethods
      
        self.options = options
        self.field_to_select = field_to_select.to_sym
      end
    end
  
    module ClassMethods
      # $> Category.options_for_select 
      # $> => [['--', nil], ['Title1', 1], ['Title2', 2], ['Title3', 3]]
      #
      # Example:
      #   <%= f.select :category_id, Category.options_for_select -%>
      def options_for_select
        rows = self.find(:all, :conditions => (options[:conditions] || {}), :order => options[:order])
        default_selection = (options[:default_text] == :first ? [] : [[options[:default_text], nil]])
        default_selection + rows.collect { |r| [r.send(field_to_select), r.id] }
      end
    end
  
    module ViewHelpers
      # obj          - object relating to whatever form you're on
      # f_key        - the foreign key relating the lookup table
      #                (assumes the 'category_id' pattern common to Rails)
      # options      - same options allowed by the select tag
      # html_options - same html_options allowed by the select tag
      #
      # Example:
      #   <% form_tag :url => project_path(@project) do -%>
      #     Title: <%= text_field :project, :title -%>
      #     Category: <%= lookup_for :project, :category_id -%>
      #   <% end -%>
      #
      # Note: lookup_for will attempt to find the association that
      #       uses the given foreign key +f_key+, but will fallback to 
      #       classifying the +f_key+ by removing the _id portion
      def lookup_for(obj, f_key, options={}, html_options={})
        object = options[:object] || instance_variable_get("@#{obj}")
        klass  = nil
        
        # find association that matches the foreign key
        object.class.reflect_on_all_associations.each do |reflection|
          if reflection.primary_key_name == f_key.to_s
            klass = reflection.class_name.constantize
            break
          end  
        end unless object.nil?
        
        begin
          klass ||= f_key.to_s.gsub(/_id$/, '').classify.constantize 
        rescue NameError
          raise(Error::InvalidModel, Error::InvalidModel.message)
        end
        raise(Error::InvalidLookup, Error::InvalidLookup.message) unless klass && klass.respond_to?(:field_to_select) && klass.respond_to?(:options_for_select)
        select(obj.to_sym, f_key.to_sym, klass.options_for_select, options, html_options)
      end
      
      # allows `lookup_for' to be used with the
      # <% form_for @object do |f| %> syntax
      module FormBuilder
        # Example:
        #   <% form_for :project do |f| -%>
        #     Title: <%= f.text_field :title -%>
        #     Category: <%= f.lookup_for :category_id -%>
        #   <% end -%>
        def lookup_for(f_key, options={}, html_options={})
          @template.lookup_for(@object_name, f_key, options.merge(:object => @object), html_options)
        end
      end
    end
    
    # error module to raise plugin specific errors
    module Error
      class CustomError < RuntimeError
        def self.message(msg=nil); msg.nil? ? @message : self.message = msg; end
        def self.message=(msg); @message = msg; end
      end
      
      # custom error classes
      class InvalidAttr < CustomError
        message "attr passed to `acts_as_lookup' does not exist"; end
      class InvalidLookup < CustomError
        message "model passed to `lookup_for' does not have the `act_as_lookup' declaration"; end
      class InvalidModel < CustomError
        message "model passed to `lookup_for' does not seem to exist"; end
    end
  end
end