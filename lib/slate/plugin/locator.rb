require File.dirname(__FILE__) + '/plugin.rb'

module Slate
  class Plugin
    class Locator < Rails::Plugin::FileSystemLocator
      # creates a new plugin instance if
      # the given path is a valid slate plugin
      def create_plugin(path)
        require path
        plugin = plugin_class(path)
        plugin.is_a?(Slate::Plugin) && plugin.valid? ? plugin : nil
      end
      
    private
      # creates a new plugin object from given path
      def plugin_class(path)
        klass = File.basename(path, '.rb').classify.constantize
        klass.new(File.dirname(path))
      end
    
      # This looks inside the given path for directories
      # and returns new Slate::Plugin instances for all
      # valid slate plugin directories
      def locate_plugins_under(base_path)
        Dir.glob(File.join(base_path, '*/*_plugin.rb')).inject([]) do |plugins, path|
          if plugin = create_plugin(path)
            plugins << plugin
          end  
          plugins
        end
      end    
    end
  end
end