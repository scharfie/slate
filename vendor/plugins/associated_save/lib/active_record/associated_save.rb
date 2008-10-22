require "enumerator"

module ActiveRecord
  module AssociatedSave
    module ClassMethods
      # Creates a callback which saves associated records
      # when passed in from a form.  An example will be much easier
      # to explain this :-)
      # 
      # Example:
      #   class Collection < ActiveRecord::Base
      #     has_many :items
      #     associated_save :items
      #   end
      #       
      #   class Item < ActiveRecord::Base
      #     belongs_to :collection
      #   end
      # 
      #   # some form:
      #   <% @collection.items.each do |item| %>
      #     <% fields_for 'collection[_items][]', item do |form| %>
      #       <%= form.text_field :name %>
      #       <%= form.hidden_field :id %>
      #     <% end %>
      #   <% end %>
      # 
      # When the collection is saved, the associated :items are
      # updated based on the data in params[:collection][:_items]
      # 
      # By default, the parameter key name is the association name
      # with a prefix of _, but this can be set to anything you want
      # by setting the :from option.
      # 
      # In the example, an after_save callback named "save_associated_items"
      # would be created.  When the callback is invoked, all associated 
      # objects defined will be updated, and anything not updated is deleted,
      # unless the :delete option is set to false (defaults to true).  This is
      # useful if you use JS to remove a set of form fields from the DOM, for
      # example.
      #
      # Note: this plugin is designed for has_many relationships,
      # since that is the most likely candidate for this type of functionality.
      def associated_save(name, options={})
        # Build reflection
        associated_reflection = associated_saves[name.to_sym] = Reflection.new(name, options)
        reflection = reflect_on_association(name)
        
        from = associated_reflection[:from]
        callback = associated_reflection[:callback]
        
        # Create the callback method
        define_method callback do
          association = send(name)
          ids_to_delete = association.map { |e| e.id }
          return unless new_objects = associated_save_objects(name)
          new_objects.map { |e| e.save }
          ids_to_delete -= new_objects.map { |e| e.id }
          
          # Delete unreferenced associated objects
          reflection.class_name.constantize.delete(ids_to_delete) if associated_reflection[:delete]
        end
        
        define_method "associated_#{name}" do
          associated_save_objects(name)
        end
        
        # Create accessor for the variable  
        attr_accessor from  
        
        # Create the callback
        after_save callback
      end
      
      # Hash of all associated save reflection data
      def associated_saves
        @associated_saves ||= HashWithIndifferentAccess.new
      end
      
      # Returns associated save reflection for given association
      def reflect_on_associated_save(association)
        associated_saves[association]
      end
    
      # Returns the name of the variable used for given association
      def associated_save_variable(association)
        reflection = reflect_on_associated_save(association)
        reflection.options[:from]
      end
    end
    
    module InstanceMethods
      # Builds objects for association
      def associated_save_objects(association)
        associated_reflection = self.class.reflect_on_associated_save(association)
        reflection = self.class.reflect_on_association(association)
        
        return nil unless from = instance_variable_get("@#{associated_reflection[:from]}")
        foreign_key = reflection.primary_key_name
        association = send(associated_reflection[:name])
        position_column = association.column_names.include?('position') ? 'position' : nil

        [*from].enum_with_index.map do |attributes, index|
          # handle hashes - grab the value
          attributes = attributes.last if Array === attributes
          next if attributes.blank?
          attributes.merge!(foreign_key => self.id)
          attributes.merge!(position_column => index) if position_column
          record = (id = attributes[:id]).blank? ? association.build : association.find_by_id(id)
          record.attributes = attributes
          record
        end.compact
      end

      # Returns data for given association from associated 
      # save variable
      def associated_save_data(association)
        from = self.class.associated_save_variable(association)
        instance_variable_get "@#{from}"
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
    
    class Reflection
      attr_accessor :options

      def initialize(name, options={})
        @options = options.reverse_merge :from => "_#{name}", :delete => true
        @options[:name]     = name
        @options[:callback] = "save_associated_#{name}"
      end
      
      def [](key)
        options[key]
      end
    end
  end
end
