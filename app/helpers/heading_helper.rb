module HeadingHelper
  # captures given text or block to use as heading
  def heading(text=nil, &block)
    content_for_variable('heading', text, &block) if text || block_given?
    @content_for_heading.blank? ? default_heading : @content_for_heading
  end
  
  def default_heading
    if respond_to?(:resource_name)
      name = resource.respond_to?(:name) ? resource.name : "(unknown #{resource_name})"
      case params[:action]
      when 'new'
        "Creating new #{resource_name.gsub(/^_/, '').humanize.downcase}"
      when 'update'
        "Saving <span>#{name}</span>"
      when 'edit'
        "Editing <span>#{name}</span>"
      when 'index'
        resource_name.gsub(/^_/, '').humanize.pluralize
      when 'search'
        "Search results for <span>#{params[:q]}</span>"
      when 'show'
        "Viewing <span>#{name}</span>"
      end
    end  
  end
end