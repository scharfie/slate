module Slate
  module ThemeSupport
    def self.included(base)
      base.class_eval do

      protected
        # Prepends theme-related view paths
        # (Note that prepend_view_path is not thread-safe 
        # according to Rails docs and should have a mutex)
        def prepend_theme_view_paths
          return true if Space.active.nil? || Space.active.theme.blank?
          self.prepend_view_path [theme_path, theme_views_path]
        end
        
        # Returns the path to the current theme in public/themes
        def theme_path
          File.join(App.root, 'public/themes', Space.active.theme.to_s)
        end
        
        # Returns the view path for the current theme's "views" folder
        def theme_views_path
          File.join(theme_path, 'views')
        end
      end
    end
  end
end