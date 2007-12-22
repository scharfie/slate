module Slate
  class ThemeMissing < Slate::Error
    message "The theme for this site is missing."; end
  class TemplateMissing < Slate::Error
    message "The template for this page is missing."; end
  
  module Builder
    THEME_TEMPLATE_ROOT = '../../public/themes/'
    
    def self.included(receiver)
      receiver.send(:helper, :builder)
      receiver.send(:helper, Helpers)
      receiver.send(:helper_method, :content_for)
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
    
    # renders the template for the current page
    def view_page
      raise Slate::ThemeMissing if (theme = @space.theme).blank?
      raise Slate::TemplateMissing if (template = @page.template).blank?
      
      template = File.join(THEME_TEMPLATE_ROOT, theme, template) rescue nil
      
      begin
        render :template => template, :layout => false
      rescue ActionController::MissingTemplate => e
        raise Slate::TemplateMissing
      end  
    end

    # renders the content for the given key in current page
    def content_for(key)
      @area = @page.content_for(key, production? ? :production : :draft)
      @area.body_html = '<em class="b-empty">(empty)</em>' if @area.new_record? && editor?
      render_to_string :partial => 'builder/area'
    end
  end
end