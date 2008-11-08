module NavigationHelper
protected
  # returns items for navigation based on
  # current context
  def items_for_navigation
    return nil if User.active.nil?
    return space_navigation_items unless Space.active.nil?    
    return admin_navigation_items if User.active.super_user?
  end
  
  # returns navgiation items for admin 
  # (super user)
  def admin_navigation_items
    tabs = ActiveSupport::OrderedHash.new
    tabs['Dashboard'] = dashboard_url
    tabs['Users'] = users_url
    tabs['Themes']     = themes_path
    tabs
  end
  
  # returns navigation items for space
  def space_navigation_items
    tabs =  ActiveSupport::OrderedHash.new
    tabs['Dashboard']  = space_dashboard_path(Space.active)
    tabs['Pages']      = space_pages_path(Space.active)
    tabs.merge!          plugin_navigation_items
    tabs['Files']      = space_assets_path(Space.active)
    tabs['Settings']   = edit_space_path(Space.active)
    tabs
  end

  # Returns navigation items for enabled plugins
  def plugin_navigation_items
    builder = Slate::Plugin::Navigation.new(self)
    
    Space.active.available_plugins.each do |plugin|
      plugin.navigation_definitions.each do |block| 
        builder.instance_eval &block
      end if plugin.enabled?
    end
    
    builder.items
  end

public
  # renders navigation toolbar
  def navigation
    items = items_for_navigation
    render(:partial => 'shared/navigation', :object => items) if items
  end
  
  # creates a new navigation item link
  def navigation_item(tab, url)
    link_to tab, url, :class => navigation_item_current?(tab) ? 'current' : nil
  end
  
  # returns true if the navigation item matches the current URL
  def navigation_item_current?(tab)
    self.current_tab == tab
  end
end