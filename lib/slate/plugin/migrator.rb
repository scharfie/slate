module Slate
  class Plugin
    class Migrator < ActiveRecord::Migrator
      class << self
        attr_accessor :plugin
      end

      def self.migrate_plugin(plugin, target_version = nil)
        self.plugin = plugin
        self.migrate(plugin.migrations_path, target_version)
      end
    
      def current_version
        self.class.plugin.schema_info.version
      end
  
      def set_schema_version(version)
        self.class.plugin.schema_info.update_attributes(
          :version => (down? ? version.to_i - 1 : version.to_i))
      end
    end
  end
end