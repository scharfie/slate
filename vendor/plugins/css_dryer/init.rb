# Register our handler with Rails.
require 'css_dryer'
ActionView::Template.register_template_handler :ncss, CssDryer::NcssHandler
