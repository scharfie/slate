class Plugin < ActiveRecord::Base
  delegate :name, :description, :to => :slate_plugin
  attr_accessor_with_default :slate_plugin do
    @slate_plugin ||= Slate.plugins.detect { |e| e.key == self.key }
  end
end