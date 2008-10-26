require 'acts_as_lookup'

ActiveRecord::Base.send(:include, RPH::ActsAsLookup)
ActionView::Base.send(:include, RPH::ActsAsLookup::ViewHelpers)
ActionView::Helpers::FormBuilder.send(:include, RPH::ActsAsLookup::ViewHelpers::FormBuilder)