class Page
  module Mount
    module ClassMethods
      def mount(key, attributes)
        find_or_initialize_by_mount_key(key) do |e|
          if e.new_record?
            attributes = attributes.with_indifferent_access
            attributes[:name] ||= key.to_s.humanize
            attributes[:template] ||= key.to_s.underscore + '.html.erb'
            e.update_attributes(attributes)
          end  
        end
      end
  
      def install_mounts
        raise "No active space" unless Space.active

        Space.active.plugins.inject([]) do |mounts, plugin|
          return mounts unless plugin = plugin.slate_plugin
          mounts += plugin.mounts.map do |key, attributes|
            mount(key, attributes)
          end
        end
      end
      
      def ensure_mount(key)
        raise "No active space" unless Space.active
        key = key.to_s
        
        Space.active.plugins.each do |plugin|
          next unless plugin = plugin.slate_plugin
          if attributes = plugin.mounts[key]
            return mount(key, attributes)
          end  
        end
      end
    end
    
    module InstanceMethods
      def mount?
        !mount_key.blank?
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end