module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module Published
      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods  
      end
    
      module ClassMethods
        # Version 0 is draft, version 1 is published, 
        # versions 2-5 are previously published 
        def acts_as_published(options={})
          options.reverse_merge! acts_as_published_default_configuration(self.name)
          
          # Define a method to access the provided configuration
          class_eval "def self.acts_as_published_configuration(); #{options.inspect}; end"

          # Add the association
          has_many :versions, options
        end
      
        # Returns hash of default options based on given
        # class name
        def acts_as_published_default_configuration(class_name)
          options = {
            :class_name  => class_name,
            :foreign_key => class_name.foreign_key,
            :dependent   => :delete_all
          }  
        end
      end
    
      module InstanceMethods
        # Accessor to class method
        def acts_as_published_configuration
          self.class.acts_as_published_configuration
        end
        
        # Increments all versions of this model
        def increment_versions
          self.class.update_all 'version = version + 1', 
            "#{acts_as_published_configuration[:foreign_key]} = #{self.id} AND version > 0"
        end

        # Removes old versions (any version >= 5) of this model
        def clear_old_versions
          self.class.delete_all "version >= 5 AND #{acts_as_published_configuration[:foreign_key]} = #{self.id}"
        end  
        
        # Publishes this model
        def publish!
          return false if new_record?
    
          returning self.clone do |published_model|
            transaction do
              increment_versions 
              clear_old_versions
              published_model.update_attributes(
                acts_as_published_configuration[:foreign_key] => self.id, 
                :version => 1, 
                :published_at => Time.now
              )
            end
          end  
        end

        # Finds currently published version
        def published_version
          versions.find_by_version(1)
        end
        
        def published?
          version == 1
        end
        
        def draft?
          version == 0
        end
      end
    end
  end
end