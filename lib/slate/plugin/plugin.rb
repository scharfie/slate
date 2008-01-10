module Slate
  class << self
    attr_accessor :plugins
  end
  
  self.plugins = []
  
  class Plugin < Rails::Plugin
    class Navigation
      attr_accessor :items
    
      # Adds item to the navigation items collection
      def add(name=nil, options={})
        (@items ||= []) << [name, options]
      end
      
      # Returns all navigation items by evaluating
      # them in the context of the given controller
      def self.items(controller)
        builder = self.new
        Slate.plugins.each do |plugin|
          plugin.navigation_definitions.each do |block| 
            controller.instance_exec(builder, &block)
          end  
        end
        builder.items || []
      end
    end
    
    class << self
      def navigation(&block)
        self.navigation_definitions << block
      end
      
      def routes(&block)
        self.route_definitions << block
      end
      
      def navigation_definitions
        @navigation_definitions ||= []
      end
      
      def route_definitions
        @route_definitions ||= []
      end
    end
    
    # Convenience accessor to class route definitions
    def route_definitions
      self.class.route_definitions
    end
    
    # Convenience accessor to class navigation definitions
    def navigation_definitions
      self.class.navigation_definitions
    end

    # Migrates this plugin to the target version
    def migrate(target_version = nil) 
      Slate::Plugin::Migrator.migrate_plugin(self, target_version)
    end
    
    # Path to migrations directory
    def migrations_path
      File.join(directory, 'db/migrate')
    end    
    
    # Returns ActiveRecord object from the plugin schema
    # table for this plugin
    def schema_info
      Slate::Plugin::SchemaInfo.find_or_create_by_name(plugin_name)
    end
    
    # Returns name of the plugin
    def plugin_name
      self.class.to_s
    end
    
    alias_method :name, :plugin_name
    
    # Returns true if the current plugin is a valid
    # Slate plugin (having an app directory and 
    # plugin file)
    def valid?
      File.directory?(directory) && 
        has_app_directory? && 
        has_plugin_file?
    end
    
    # Loads plugin (initializes dependencies and adds
    # plugin to Slate.plugins)
    def load(initializer)
      return if loaded?

      # initialize dependences and load plugin.rb
      init_dependencies(initializer)

      # add this plugin to the plugins collection
      Slate.plugins << self
      @loaded = true
    end
    
    # Initializes dependencies - adds necessary
    # paths to the loading paths array
    def init_dependencies(initializer)
      config = initializer.configuration

      # prepare paths for dependencies
      controller_path = File.join(app_path, 'controllers')
      model_path = File.join(app_path, 'models')
      helper_path = File.join(app_path, 'helpers')
      
      Dependencies.load_paths << controller_path
      Dependencies.load_paths << model_path
      Dependencies.load_paths << helper_path
      
      # we must explicitly tell Rails that app/controllers
      # contains valid controllers (security issue)
      config.controller_paths << controller_path
      
      # add views to the view paths
      ActionController::Base.view_paths << File.join(app_path, 'views')
    end
    
  private
    # Path to the /app directory
    def app_path
      File.join(directory, 'app')
    end
    
    # Path to the plugin.rb file
    def plugin_file_path
      Dir.glob(File.join(directory, '*_plugin.rb')).first
    end
    
    # Determines if the plugin contains a valid
    # /app directory
    def has_app_directory?
      File.directory?(app_path)
    end
    
    # Determines if the plugin contains a valid
    # plugin.rb file
    def has_plugin_file?
      File.file?(plugin_file_path)
    end
  end
end