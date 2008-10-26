require 'rubygems'
require 'action_controller'
require 'action_view'
require 'active_support'
require File.join(File.dirname(__FILE__), "../lib/acts_as_lookup")

ActionView::Base.send(:include, RPH::ActsAsLookup::ViewHelpers)
ActionView::Helpers::FormBuilder.send(:include, RPH::ActsAsLookup::ViewHelpers::FormBuilder)

class HashWithIndifferentAccess
  # override #id explicitly to alleviate
  # the `use #object_id instead' message
  def id
    self.send(:[], :id)
  end
  
  # allow obj.title to return obj[:title]
  def method_missing(name, *args)
    self.send(:[], name.to_sym)
  end
end

# fake ActiveRecord class to avoid dealing
# with actual DB connections
module MockAR
  class Base
    # simulates ActiveRecord::Base.send(:include, RPH::ActsAsLookup)
    # (init.rb)
    include RPH::ActsAsLookup
    
    attr_accessor :title
    
    # mock out the find to simulate real
    # ActiveRecord objects being returned from DB
    def self.find(*args)
      mock_fields
    end
    
    private
      def self.mock_fields
        [
          HashWithIndifferentAccess.new({:id => 1, :title => 'Ryan'}),
          HashWithIndifferentAccess.new({:id => 2, :title => 'Paul'}),
          HashWithIndifferentAccess.new({:id => 3, :title => 'Heath'})
        ]
      end
  end
end