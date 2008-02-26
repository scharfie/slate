class Slate::Controller < ApplicationController
  # Path to /app/controllers within a particular plugin
  cattr_accessor :controller_base
  before_filter :prepend_plugin_view_path
  
protected
  # Prepends the path to the plugins view path
  def prepend_plugin_view_path
    self.class.prepend_view_path self.class.controller_base / '../views'
  end

public  
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