module Slate
  class ThemeMissing < Slate::Error
    message "The theme for this site is missing."; end
  class TemplateMissing < Slate::Error
    message "The template for this page is missing."; end
  
  module Builder
    def self.included(base)
      base.send(:helper, :builder)
      base.send(:helper, Helpers)
      base.send(:helper_method, :content_for)
    end
    
    module Helpers
      # returns true if in editor mode
      def editor?
        !preview? && !production?
      end
    
      # returns true if in preview mode
      def preview?
        params[:mode] == 'preview'
      end
    
      # returns true if in production mode
      def production?
        params[:mode] == 'production'
      end
    end
    
    include Helpers

  protected
    # Loads mount helper
    # (based on pluralized form of behavior object's class)
    # For example, a page with a behavior object of type Blog would
    # expect a helper module BlogsHelper
    def load_mount_helper
      return unless @page.mount?

      # Why does it have to be this hard?  Calling +self.class.helper+ doesn't
      # work... the template already exists at that point :-/
      helper_module = (@page.mount_key.to_s + '_helper').classify.constantize
      response.template.extend helper_module
    rescue
      nil
    end
    
    # def load_plugin_helpers
    #   Space.active.plugins.each do |plugin|
    #     next unless plugin = plugin.slate_plugin
    #     
    #   end
    # end

  public
    # Renders the template for the current page
    def view_page
      raise Slate::ThemeMissing if (theme = @space.theme).nil?
      raise Slate::TemplateMissing if (template = @page.template).blank?
      
      template = 'templates' / template
      
      load_mount_helper
      
      begin
        render :template => template, :layout => false
      rescue ActionView::MissingTemplate => e
        raise Slate::TemplateMissing
      end  
    end

    # Renders the content for the given key in current page
    def content_for(key)
      @area = @page.content_for(key, production? ? :production : :draft)
      @area.body_html = '<em class="b-empty">(empty)</em>' if @area.new_record? && editor?
      render_to_string :partial => 'builder/area'
    end
  end
end