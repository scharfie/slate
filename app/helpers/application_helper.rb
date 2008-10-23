module ApplicationHelper
  # custom version of Rails content_for which
  # actually uses the 'content' argument
  def content_for_variable(name, content=nil, &block)
    var = instance_variable_get("@content_for_#{name}") || ''
    var << content unless content.blank?
    var << capture(&block) if block_given?
    instance_variable_set("@content_for_#{name}", var)
  end
  
  # captures given text or block to use as heading
  def heading(text=nil, &block)
    content_for_variable('heading', text, &block)
  end
  
  # finds all spaces and renders the space chooser
  def space_chooser
    spaces = Space.find(:all, :order => 'name')
    render :partial => 'shared/space_chooser', :locals => { :spaces => spaces }
  end
  
  # creates 'Cancel' link to given URL
  def cancel_link(url=nil)
    url = resources_url if url.nil? && respond_to?(:resources_url)
    link_to 'Cancel', url, :class => 'cancel'
  end
  
  # creates an image tag to given glyph 
  def glyph(name, options={})
    options[:class] = [options[:class], 'glyph'].compact.join(' ')
    image_tag("glyphs/#{name}.png", options)
  end
  
  # captures given block and stores the result
  # for use with yield :head (placed within HEAD tag)
  def head(text=nil, &block)
    content_for_variable('head', text, &block)
  end
  
  # outputs a span tag wrapping the given text
  def span(text, options={})
    content_tag(:span, text, options)
  end
  
  # escapes the given Javascript code
  # (to be used like the h() helper)
  def js(text=nil)
    escape_javascript(text)
  end
  
  # Returns a link 'slate' to the main dashboard
  def dashboard_heading
    span link_to('slate', dashboard_path), :class => 'slate'
  end
  
  # Returns a link to the active space
  def space_heading
    span link_to(Space.active.name, space_dashboard_path(Space.active)), 
      :class => 'space' if Space.active
  end
  
  # Returns 'Administrator' if super user
  def admin_heading
    span 'Administrator', :class => 'space' if super_user?
  end
  
  def fieldset(legend, &block)
    locals = {
      :legend => legend, 
      :fields => capture(&block)
    }
    
    result = render(:partial => 'forms/fieldset', :locals => locals)
    concat result, block.binding
  end
end