module Slate
  module PermalinkColumn
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # creates a new permalink for given column.
      # the permalink name is 'permalink', and the 
      # given column name is the source column to
      # permalink
      def permalink_column(name, options={})
        permalink_name = 'permalink'
        options.reverse_merge! :glue => '_'

        # creates new method for permalink name
        # which will return the proper permalink
        define_method permalink_name do
          self[permalink_name] ||= self[name].permalink(options[:glue])
        end

        # before save callback which ensures that
        # a permalink exists for given record
        before_save do |record|
          record.send(permalink_name)
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Slate::PermalinkColumn