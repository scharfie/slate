module Slate
  class << self
    attr_accessor :plugins
  end
  
  self.plugins = []
  
  class Plugin < Rails::Plugin
    def valid?
      File.directory?(directory) && 
        has_app_directory? && 
        has_plugin_file?
    end
    
    def load(initializer)
      return if loaded?

      # initialize dependences and load plugin.rb
      init_dependencies(initializer)
      # TODO: evaluate_plugin_rb(initializer)

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
      
      Dependencies.load_paths << controller_path
      Dependencies.load_paths << model_path
      
      # we must explicitly tell Rails that app/controllers
      # contains valid controllers (security issue)
      config.controller_paths << controller_path      
    end
    
  private
    # Path to the /app directory
    def app_path
      File.join(directory, 'app')
    end
    
    # Path to the plugin.rb file
    def plugin_file_path
      File.join(directory, 'plugin.rb')
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