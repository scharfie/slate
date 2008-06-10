# Register our handler with Rails.
require 'css_dryer'
if defined?(ActionView::Template)   # Rails 2.1
  ActionView::Template.register_template_handler 'ncss', CssDryer::NcssHandler
else
  ActionView::Base.register_template_handler 'ncss', CssDryer::NcssHandler
end

# Monkey patch for asset packaging support.
require 'asset_tag_helper_hack'
