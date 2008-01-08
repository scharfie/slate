module Slate
  class Plugin
    class Migrator < ActiveRecord::Migrator
      def self.migrate_plugins
        Slate.plugins.each do |plugin|
          plugin.migrator.migrate
        end
      end
  
      def initialize(plugin)
        @plugin = plugin
        @migrations_path = File.join(@plugin.directory, '/db/migrate')
      end
  
      def migrate_with_plugin_support(how = :up)
        raise StandardError.new("This database does not yet support migrations") unless ActiveRecord::Base.connection.supports_migrations?
    
        if [:up, :down].include?(how)
          @direction = how
          @target_version = nil
        else
          @target_version = how
          case
            when @target_version.nil?, current_version < @target_version
              @direction = :up
            when current_version > @target_version
              @direction = :down
            when current_version == @target_version
              return # You're on the right version
          end
        end
    
        migrate_without_plugin_support
      end
      alias_method_chain :migrate, :plugin_support
    
      def current_version
        @plugin.schema_info.schema_version
      end
  
      def set_schema_version(version)
        @plugin.schema_info.update_attributes(:schema_version => (down? ? version.to_i - 1 : version.to_i))
      end
    end
  end
end