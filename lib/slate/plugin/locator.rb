require File.dirname(__FILE__) + '/plugin.rb'

module Slate
  class Plugin
    class Locator < Rails::Plugin::FileSystemLocator
      # creates a new Slate::Plugin instance if
      # the given path is a valid slate plugin
      def create_plugin(path)
        plugin = Slate::Plugin.new(path)
        plugin.valid? ? plugin : nil
      end
      
    private
      # This looks inside the given path for directories
      # and returns new Slate::Plugin instances for all
      # valid slate plugin directories
      def locate_plugins_under(base_path)
        Dir.glob(File.join(base_path, '*')).inject([]) do |plugins, path|
          if File.directory?(path) && plugin = create_plugin(path)
            plugins << plugin
          end
          plugins
        end
      end    
    end
  end
end