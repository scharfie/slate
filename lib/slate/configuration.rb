module Slate
  # shortcut for accessing the configuration
  # Slate.config is the same as Slate::Configuration.config
  def self.config(&block)
    Configuration.config(&block)
  end
  
  class Configuration
    cattr_accessor :settings

    # returns configuration object
    # (creates if necessary)
    def self.settings
      @@settings ||= ConfigurationHash.new
    end
    
    # returns the current configuration
    # by passing a block you can easily edit the
    # configuration values
    def self.config
      block_given? ? yield(self.settings) : self.settings
    end

    # loads configuration files from the given path
    def self.process(path)
      Dir.glob(path).each { |config_file| load config_file }
    end
    
    # shortcut Configuration.config.something
    # to Configuration.something
    def self.method_missing(name, *args, &block)
      self.config.send(name, *args, &block)
    end
  end
  
  # specialized hash for storing configuration settings
  class ConfigurationHash < Hash
    # ensure that default entries always produce 
    # instances of the ConfigurationHash class
    def default(key=nil)
      include?(key) ? self[key] : self[key] = self.class.new
    end
    
    # retrieves the specified key and yields it
    # if a block is provided
    def [](key, &block)
      block_given? ? yield(super(key)) : super(key)
    end
    
    # provides member-based access to keys
    # i.e. params.id === params[:id]
    # note: all keys are converted to symbols
    def method_missing(name, *args, &block)
      if name.to_s.ends_with? '=' 
        send :[]=, name.to_s.chomp('=').to_sym, *args, &block
      else
        send :[], name.to_sym, &block
      end    
    end
  end
end