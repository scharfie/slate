module Slate
  module ThemeSupport
    def self.included(base)
      base.class_eval do
        # returns the view path for the current theme
        def theme_view_path
          File.join(App.root, 'public/themes', 
            Space.active.theme, 'views') if Space.active && !Space.active.theme.blank?
        end

        # returns view paths with theme_view_path
        def view_paths_with_theme
          ([theme_view_path] + view_paths_without_theme).uniq.compact
        end
      
        # alias the normal view_paths
        alias_method_chain :view_paths, :theme
      end
    end
  end
end