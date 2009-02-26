module Slate
  class << self
    def plugins
      @plugins ||= ActiveSupport::OrderedHash.new
    end
  end
  
  class Plugin
    attr_accessor :key, :directory
    
    def self.install(key, directory=nil, &block)
      directory ||= File.dirname(eval('__FILE__', block))
      plugin = new(key, directory)
      block.call(plugin)
      Slate.plugins[key] = plugin
    end
    
    def initialize(key, directory)
      @key = key
      @directory = directory
      init_dependencies
    end
    
    # Initializes dependencies
    def init_dependencies
      # prepare paths for dependencies
      app_path        = File.join(@directory, 'app')
      controller_path = File.join(app_path, 'controllers')
      model_path      = File.join(app_path, 'models')
      helper_path     = File.join(app_path, 'helpers')
      
      # Remove plugin paths from load once since we want them
      # to be reloadable
      [controller_path, model_path, helper_path].each do |path|
        ActiveSupport::Dependencies.load_once_paths.delete(path)
      end
    end    
    
    # Returns true if:
    #   key is blank
    #   key matches plugin key
    #   key with "-slate-plugin" suffix matches plugin key
    def match?(key)
      key.blank? || self.key == key || self.key == (key + '-slate-plugin')
    end
    
    def navigation(&block)
      self.navigation_definitions << block
    end
    
    def navigation_definitions
      @navigation_definitions ||= []
    end
    
    def mounts
      @mounts ||= ActiveSupport::OrderedHash.new
    end
    
    def mount(key, attributes={})
      self.mounts[key] = attributes
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
  end
end