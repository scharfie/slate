module Slate
  module Routing
    module Mapper
      # This is a helper method for defining space 
      # resources from plugins
      # 
      # Example: 
      #   clas MyPlugin < Slate::Plugin
      #     routes do |map|
      #       map.with_space { |space| space.resources :articles }
      #     end
      #   end
      # 
      # The above example would be like this in routes.rb:
      #   map.resources :spaces { |space| space.resources :articles }
      def with_space(&block)
        with_options :path_prefix => 'spaces/:space_id', 
          :name_prefix => 'space_', &block
      end
      
      # This routing helper provides an easy interface for
      # creating a route that will be used for the public-side
      # of slate (i.e. outside of slate admin)
      def public_routes(&block)
        with_options :controller => 'public',
          :conditions => { :not_subdomain => 'slate' }, 
          &block
      end
    end
  end
end

ActionController::Routing::RouteSet::Mapper.class_eval do
  include Slate::Routing::Mapper
end  