require 'fileutils'

module Slate
  class Plugin
    # Returns path to assets directory in plugin
    def source_assets_path
      File.join(directory, 'assets')
    end
    
    # Returns target path for assets (RAILS_ROOT/public)
    def target_assets_path
      File.join(RAILS_ROOT, 'public')
    end
    
    # Returns target path for given asset by replacing
    # the source path directory with target path directory
    def target_asset_path(path)
      path.sub(source_assets_path, target_assets_path)
    end

    # Returns directory glob of all entries in 
    # source assets path directory
    def assets
      @assets ||= Dir["#{source_assets_path}/**/*"].sort
    end
    
    # Returns all file assets in source assets directory
    def asset_files
      assets.select { |d| File.file?(d) }
    end
    
    # Returns all directories in source assets directory
    def asset_directories
      assets.select { |d| File.directory?(d) }
    end
    
    # Creates directories in target assets directory
    # based on directory structure found in source assets
    # directory
    def create_asset_directories
      asset_directories.each do |path|
        target = target_asset_path(path)
        target_exists = File.exist?(target)
   
        unless target_exists
          begin
            FileUtils.mkdir_p(target)
          rescue Exception => e
            raise "  ! Could not create directory #{target}:\n" + e  
          end  
        end  
      end
    end

    # Copies all source assets to target asset directory.
    def copy_assets(force=true)
      create_asset_directories
  
      tally = { :create => 0, :update => 0 }
  
      asset_files.each do |file|
        target = target_asset_path(file)
        target_exists = File.exist?(target)
   
        # We do not overwrite the file if the file exists and (1) is identical
        # or (2) we're allowed to overwrite the file
        unless target_exists && (FileUtils.identical?(file, target) || !force)
          action = target_exists ? :update : :create
          puts "   #{action} #{target} ..."
          
          begin
            FileUtils.cp(file, target)
            tally[action] += 1
          rescue Exception => e
            raise "  ! Could not copy #{file} to #{target}:\n" + e
	        end
        end
      end
      
      tally
    end
      
    class Assets
      class << self
        attr_accessor :plugin
        
        def plugin=(plugin)
          @plugin = plugin ? plugin.classify : nil
        end
        
        def matches_plugin?(plugin)
          self.plugin.nil? || self.plugin == plugin.name
        end
        
        # Returns list of all assets for each plugin
        # or specified plugin
        def list(plugin=nil)
          self.plugin = plugin
          
          Slate.plugins.map do |p|
            next unless matches_plugin?(p)
            [p.name, p.assets]
          end.compact
        end
        
        # Copies all assets for each plugin or specified
        # plugin
        def copy(plugin, force=true)
          self.plugin = plugin
          
          Slate.plugins.each do |plugin|
            next unless matches_plugin?(plugin)
            puts "\n #{plugin.name} assets: "
            tally = plugin.copy_assets(force)
            puts tally.values.sum == 0 ? 
              "   No new assets." :
              "   #{tally.values.sum} file(s) copied/updated."
          end
        end

        # Updates all assets for each plugin or specified
        # plugin
        def update(plugin)
          copy plugin, false
        end
      end
    end
  end
end