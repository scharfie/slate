module Slate
  # Ideally, Migrator should be namespaced within
  # Slate::Plugin, but Rake didn't seem happy about that
  class Migrator < ::ActiveRecord::Migrator
    class << self
      attr_accessor :plugin
    
      # Create the plugin schema migrations table
      def initialize_plugin_schema_migrations_table
        connection = ActiveRecord::Base.connection
        sm_table = self.plugin_schema_migrations_table_name

        unless connection.tables.detect { |t| t == sm_table }
          connection.create_table(sm_table, :id => false) do |t|
            t.column :name,    :string, :null => false
            t.column :version, :string, :null => false
          end
        
          connection.add_index sm_table, [:version, :name], :unique => true,
            :name => 'unique_plugin_schema_migrations'
        end
      end

      # Invokes block for all plugins matching given key
      def with_plugins(key=nil, &block)
        Slate.plugins.each do |plugin|
          if plugin.match?(key)
            puts "** Slate plugin: #{plugin.key}"
            yield(self.plugin = plugin)
          end  
        end
      end
      
      def for(plugin)
        self.new(nil, (self.plugin = plugin).migrations_path)
      end
    
      # Migrate specified plugin to target version
      def migrate(key, target_version=nil)
        with_plugins(key) do |plugin|
          super(plugin.migrations_path, target_version)
        end
      end
    
      # Migrate specified plugin in given directory to target version
      def run(direction, key, target_version=nil)
        with_plugins(key) do |plugin|
          super(direction, plugin.migrations_path, target_version)
        end
      end

      # Rollback specified plugin the given number of steps
      def rollback(key, step)
        with_plugins(key) do |plugin|
          super(plugin.migrations_path, step)
        end
      end

      # Plugins use a separate migrations table
      def schema_migrations_table_name
        ActiveRecord::Base.table_name_prefix + 
          'plugin_schema_migrations' + 
        ActiveRecord::Base.table_name_suffix
      end
    
      alias_method :plugin_schema_migrations_table_name, 
        :schema_migrations_table_name

      # Get all migration version for the current plugin
      def get_all_versions
        raise "No plugin specified" if plugin.nil?
        ActiveRecord::Base.connection.select_values("
          SELECT version 
          FROM #{schema_migrations_table_name} 
          WHERE name = '#{plugin.name}'"
        ).map(&:to_i).sort
      end
    end

    def initialize(direction, migrations_path, target_version = nil)
      raise StandardError.new("This database does not yet support migrations") unless ActiveRecord::Base.connection.supports_migrations?
      self.class.initialize_plugin_schema_migrations_table
      @direction, @migrations_path, @target_version = direction, migrations_path, target_version      
    end

    # Update the migrations table
    def record_version_state_after_migrating(version)
      sm_table = self.class.schema_migrations_table_name

      @migrated_versions ||= []
      if down?
        @migrated_versions.delete(version.to_i)
        ActiveRecord::Base.connection.update("DELETE FROM #{sm_table} WHERE version = '#{version}' AND name = '#{self.class.plugin.name}'")
      else
        @migrated_versions.push(version.to_i).sort!
        ActiveRecord::Base.connection.insert("INSERT INTO #{sm_table} (version, name) VALUES ('#{version}', '#{self.class.plugin.name}')")
      end
    end  
  end
end