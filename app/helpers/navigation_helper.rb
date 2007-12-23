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
    items = []
    items << ['Dashboard', { :matches => 'dashboard', :url => dashboard_url }]
  end
  
  # returns navigation items for space
  def space_navigation_items
    items =  Array.new
    items << ['Dashboard', { :match => :exact, :url => space_dashboard_path(Space.active) }]
    items << 'Pages'
    items << ['Files', { :matches => 'assets', :url => space_assets_path(Space.active) }]
    items += plugin_navigation_items
    items << ['Settings', { :match => :exact, :url => edit_space_path(Space.active) }]
  end

  # returns navigation items defined in plugins
  def plugin_navigation_items
    builder = Slate::Plugin::Navigation.new
    Slate.plugins.each do |plugin|
      plugin.navigation_definitions.each { |block| self.instance_exec(builder, &block) } #block.call(builder, controller) }
    end
    builder.items
  end

public
  # renders navigation toolbar
  def navigation
    items = items_for_navigation
    return nil if items.nil?
    
    render :partial => 'shared/navigation', :object => items
  end
  
  # creates a new navigation item link
  def navigation_item(item, options={})
    options_for_navigation_item(item, options ||= {})
    link_to options[:name], options[:url], options[:html]
  end
  
  # prepares options for navigiation item
  def options_for_navigation_item(item, options={})
    options[:url] ||= send('hash_for_space_' + item.downcase + '_url', :space_id => Space.active)
    options[:name] ||= item
    html_options = (options[:html] ||= {})
    (html_options[:class] ||= '') << ' current' if navigation_item_current?(options)
    html_options[:class].strip! unless html_options[:class].nil?
    options.update :html => html_options
  end
  
  # returns true if the navigation item matches the current URL
  def navigation_item_current?(options)
    if options[:match] == :exact
      url_for(options[:url]) == url_for
    else  
      options[:matches] ||= options[:url][:controller]
      options[:matches] == controller.controller_name
    end  
  end
end