require 'inherit_views'

defined?(ActionController) && ActionController::Base.extend(InheritViews::ActMethod)
defined?(ActionMailer) && ActionMailer::Base.extend(InheritViews::ActMethod)
defined?(ActionView) && ActionView::Base.send(:include, InheritViews::ActionView)