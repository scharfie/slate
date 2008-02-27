module BuilderHelper
  module Base
    # includes CSS and JS files for working with
    # editable sections
    def support_files
      result = %{
        #{stylesheet_link_tag 'builder'}
        #{javascript_include_tag 'jquery', 'slate/builder'}
      } if editor? && slate?
    end
    
    # renders the support toolbar
    def support_toolbar
      render :partial => 'builder/support_toolbar' if slate?
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
  
  include Base
  include Admin
end