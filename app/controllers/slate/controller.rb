class Slate::Controller < ApplicationController
  # Path to /app/controllers within a particular plugin
  cattr_accessor :controller_base
  
  # Returns custom view path for this plugin
  def self.view_path_for_plugin
    File.join(self.controller_base, '../views')
  end
  
  def self.view_paths
    [view_path_for_plugin, super].flatten.uniq
  end
  
  # Sets the controller_base path by using the caller
  def self.inherited(subclass)
    begin
      here = (/^(.+)?:\d+/ =~ caller[0]) ? File.dirname($1) : nil
      base = File.expand_path(here)
      subclass.controller_base = base
    ensure  
      super
    end
  end
end