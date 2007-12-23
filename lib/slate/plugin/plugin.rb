module Slate
  class << self
    attr_accessor :plugins
  end
  
  self.plugins = []
  
  class Plugin < Rails::Plugin
    class << self
      def routes(&block)
        self.route_definitions << block
      end
    
      def route_definitions
        @route_definitions ||= []
      end  
    end
    
    # convenience accessor to class route definitions
    def route_definitions
      self.class.route_definitions
    end

    def valid?
      File.directory?(directory) && 
        has_app_directory? && 
        has_plugin_file?
    end
    
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