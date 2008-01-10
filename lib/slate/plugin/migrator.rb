module Slate
  class Plugin
    class Migrator < ActiveRecord::Migrator
      class << self
        attr_accessor :plugin
      end

      # Migrates the specified plugin to given version
      def self.migrate_plugin(plugin, target_version = nil)
        self.plugin = plugin
        self.migrate(plugin.migrations_path, target_version)
      end

      # Returns current version of plugin from plugin schema
      # table
      def current_version
        self.class.plugin.schema_info.version
      end
  
      # Updates version of plugin in plugin schema table
      def set_schema_version(version)
        self.class.plugin.schema_info.update_attributes(
          :version => (down? ? version.to_i - 1 : version.to_i))
      end
    end
  end
end