# Register our handler with Rails.
require 'css_dryer'
ActionView::Base.register_template_handler 'ncss', CssDryer::NcssHandler
