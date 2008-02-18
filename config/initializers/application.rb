# configure slate
require 'extensions/core'
require 'extensions/active_record'

require 'slate/error'
require 'slate/configuration'
require 'slate/compiled_column'
require 'slate/permalink_column'

# ZIP file support (assets)
require 'zip/zip'

# default slate configuration
Slate::Configuration.config do |config|
  config.users.require_verification = true
  config.users.require_approval     = true
  config.users.login_attempts       = 5
  config.users.password_salt        = nil
  
  # Sets the image processor used by attachment_fu
  # Valid values: ImageScience, MiniMagick, Rmagick[1]
  # [1] Currently, Rmagick doesn't seem to be working
  config.assets.processor           = 'ImageScience'
end

# load extra configuration files from config/slate
Slate::Configuration.process File.join(RAILS_ROOT, "config/slate/*.rb")
ActionView::Base.default_form_builder = Slate::FormBuilder