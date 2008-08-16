module BuilderHelper
  module Base
    # includes CSS and JS files for working with
    # editable sections
    def support_files
      result = %{
        #{stylesheet_link_tag 'builder'}
        #{javascript_include_tag 'jquery', 'slate/builder'}
      } if (editor? || preview?) && slate?
    end
    
    # renders the support toolbar
    def support_toolbar
      render :partial => 'builder/support_toolbar' if slate?
    end
  
    # Returns URL path to the current theme
    def theme_path
      '/themes' / @space.theme
    end
    
    # Renders partial with given name
    def partial(name, options={})
      render options.merge!(:partial => qualified_theme_path(name))
    end
    
    # Makes the given name into a qualified theme path
    # by prepending the theme name (unless the name begins
    # with 'shared/')
    # 
    # This is primarily used when rendering partials with
    # the +partial+ helper
    def qualified_theme_path(name)
      name = name.to_s
      name = @space.theme / name unless name.starts_with?('shared/')
      name
    end
  end
  
  module Admin
    # creates link to editor for given area
    def edit_area_link(area)
      link_to glyph('application_edit'), 
        edit_space_page_area_url(@space.id, @page.id, area.key), 
        :class => 'b-area'
    end
    
    # creates link to toggle area as default
    def toggle_area_link(area)
      return nil if area.new_record? || area.using_default?(@page)
      image = area.default? ? 'heart' : 'heart_add'
      
      return nil if image.nil?
      link_to glyph(image), toggle_space_page_area_path(@space.id, @page.id, area.key),
        :title => 'Set/unset this area as default',
        :class => 'b-toggle'
    end
    
    # creates link to clear the area (destroy)
    def clear_area_link(area)
      return nil if area.new_record? || area.using_default?(@page)
      
      link_to glyph('bin_empty'), space_page_area_path(@space.id, @page.id, area.key),
        :method => :delete, :confirm => 'Remove content for this area and page?'
    end
    
    # returns CSS class names for given area
    def area_class(area)
      if area.default?
        area.default?(@page) ? 'b-default' : 'b-u-default'
      end  
    end
  end
  
  module Navigation
    # Returns the active page
    def active_page
      @page
    end
    
    # Returns true if the given page is active
    def active_page?(page)
      page == active_page
    end
    
    # Returns true if given page is a parent of 
    # the active page
    def parent_of_active_page?(page)
      active_page.ancestor?(page)
    end
    
    # Returns link to given page
    # It will also attach the class 'active' to the link
    # if the page is the active page
    def link_to_page(page, options={})
      (options[:class] ||= '') << ' active' if active_page?(page)
      (options[:class] ||= '') << ' has-active' if parent_of_active_page?(page)
      options[:href] = slate? ? space_page_path(@space, page) : page.permalink
      options[:href] = '/' if options[:href].blank?
      content_tag :a, page.name, options
    end
    
    # Returns top-level pages as UL
    def site_menu(options={})
      pages = @space.pages.root.children
      links = pages.map { |e| content_tag :li, link_to_page(e) }
      content_tag :ul, links.join, options
    end
  end
  
  include Base
  include Admin
  include Navigation
end