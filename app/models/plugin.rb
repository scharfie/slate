class Plugin < ActiveRecord::Base
  delegate :name, :description, :navigation_definitions, :mounts,
    :to => :slate_plugin
  
  attr_accessor_with_default :slate_plugin do
    @slate_plugin ||= Slate.plugins[self.key]
  end
  
  # Enables this plugin
  def enable!
    enabled? ? self : toggle!(:enabled)
  end
  
  # Disables this plugin
  def disable!
    enabled? ? toggle!(:enabled) : self
  end
end