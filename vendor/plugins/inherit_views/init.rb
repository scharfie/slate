require 'ardes/inherit_views'

ActionController::Base.send :extend, Ardes::InheritViews::ActionController
ActionView::Base.send :include, Ardes::InheritViews::ActionView