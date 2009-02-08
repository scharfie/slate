module Slate
  class << self
    attr_accessor :plugins
  end
  
  self.plugins = []
  
  class Plugin < ::Rails::Plugin
    class << self
      attr_accessor :name, :description
      
      def name(value=nil)
        @name = value if value
        @name
      end
      
      def description(value=nil)
        @description = value if value
        @description
      end
    end
    
    # Returns true if:
    #   key is blank
    #   key matches plugin key
    #   key with "-slate-plugin" suffix matches plugin key
    def match?(key)
      key.blank? || self.key == key || self.key == key.+('-slate-plugin')      
    end
    
    class Navigation
      attr_accessor :items
      attr_accessor :controller
      
      # Creates a new Navigation builder
      def initialize(controller)
        @controller = controller
      end
    
      # Adds item to the navigation items collection
      def add(name=nil, options={})
        (@items ||= []) << [name, options]
      end
      
      def []=(key, value)
        add(key, value)
      end
      
      # Returns items or empty array
      def items
        @items || []
      end
      
      # Pass all other method calls to the controller
      # (for named routes, etc.)
      def method_missing(m, *args, &block)
        controller.send(m, *args, &block)
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
      
      def mounts
        @mounts ||= ActiveSupport::OrderedHash.new
      end
      
      def mount(key, attributes={})
        self.mounts[key] = attributes
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
    
    def mounts
      self.class.mounts
    end

    # Path to migrations directory
    def migrations_path
      File.join(directory, 'db/migrate')
    end
    
    # Returns true if there are pending migrations
    def pending_migrations?
      Slate::Migrator.for(self).pending_migrations.any?
    end
    
    # Renders error message to stderr if the plugin
    # cannot be loaded due to pending migrations
    def pending_migrations_error
      message = "   Migrations pending: please run 'rake plugins:migrate PLUGIN=#{key}'"
      $stderr.puts message
    end
    
    # Returns name of the plugin
    def plugin_name
      self.class.to_s
    end
    
    # Returns plugin key name (the directory name of the plugin)
    #   For example, a plugin in vendor/plugins/something-slate-plugin
    #   would have a key of 'something-slate-plugin'
    def key
      @name
    end
    
    # Returns the "friendly" name of the plugin
    def name
      self.class.name || plugin_name.gsub(/_plugin/i, '').humanize
    end
    
    # Returns the description of the plugin
    def description
      self.class.description
    end
    
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

      # Note - the pending migrations check is currently 
      # disabled until I figure out how to make it only run
      # on server boot - otherwise it causes issues with rake, etc.
      
      # Prevent this plugin from loading if we have pending migrations
      # pending_migrations_error and return if pending_migrations?

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
      
      ActiveSupport::Dependencies.load_paths << controller_path
      ActiveSupport::Dependencies.load_paths << model_path
      ActiveSupport::Dependencies.load_paths << helper_path
      
      # we must explicitly tell Rails that app/controllers
      # contains valid controllers (security issue)
      config.controller_paths << controller_path
      
      # add views to the view paths
      ActionController::Base.append_view_path File.join(app_path, 'views')
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