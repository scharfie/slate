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
          has_many :versions, options.except(:versions)
          belongs_to :original_version, :class_name => options[:class_name], :foreign_key => options[:foreign_key]
          named_scope :published, :conditions => 'version = 1'
          named_scope :draft, :conditions => 'version = 0'
          
          a = table_name
          b = a + '_versions'
          
          named_scope :unpublished, 
            :select => "#{a}.*",
            :joins => "LEFT OUTER JOIN #{a} #{b} ON #{a}.id = #{b}.#{options[:foreign_key]}",
            :conditions => "#{a}.version = 0 AND #{b}.id IS NULL"

          named_scope :on_date, Proc.new { |year, month, day|
            conditions = [connection.year('published_at') + ' = ?']
            variables  = [year.to_i]
    
            if month
              conditions << connection.month('published_at') + ' = ?'
              variables  << month.to_i
      
              if day
                conditions << connection.day('published_at') + ' = ?'
                variables  << day.to_i
              end
            end
    
            { :conditions => [conditions.join(' AND '), variables].flatten }
          }
        end
      
        # Returns hash of default options based on given
        # class name
        def acts_as_published_default_configuration(class_name)
          options = {
            :class_name  => class_name,
            :foreign_key => class_name.foreign_key,
            :dependent   => :delete_all,
            :versions    => 4
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

        # Removes old versions (any version > max) of this model
        def clear_old_versions
          self.class.delete_all "version > #{acts_as_published_configuration[:versions]} AND #{acts_as_published_configuration[:foreign_key]} = #{self.id}"
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

        # Finds a particular version
        def find_version(v)
          return self if version == v
          
          # Finding a version is easy if we're in the draft object
          return versions.find_by_version(v) if draft?

          original_version.find_version(v)
        end

        # Finds currently published version
        def published_version
          published_version? ? self : find_version(1)
        end
        
        # Finds draft version
        def draft_version
          draft? ? self : original_version
        end        
        
        def published_version?
          version == 1
        end
        
        def draft_version?
          version == 0
        end
        
        alias_method :published?, :published_version?
        alias_method :draft?, :draft_version?
      end
    end
  end
end