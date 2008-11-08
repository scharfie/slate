# configure slate
require 'extensions/core'
require 'extensions/active_support'
require 'extensions/active_record'
require 'extensions/inflector'

require 'slate/error'
require 'slate/configuration'
require 'slate/compiled_column'
require 'slate/permalink_column'

# ZIP file support (assets)
require 'zip/zip'

# default slate configuration
Slate::Configuration.config do |config|
  config.users.login_attempts       = 5
  config.users.password_salt        = nil
  
  # Sets the image processor used by attachment_fu
  # Valid values: ImageScience, MiniMagick, Rmagick[1]
  # [1] Currently, Rmagick doesn't seem to be working
  config.assets.processor           = 'ImageScience'
end

# load extra configuration files from config/slate
Slate::Configuration.process File.join(Rails.root, "config/slate/*.rb")
ActionView::Base.default_form_builder = Slate::FormBuilder
Ardes::ResourcesController.actions = Slate::ResourcesController::Actions

# Patch ActiveRecord::Migrator for auto_migrations
class ActiveRecord::Migrator
  class << self
    alias_method :schema_info_table_name, :schema_migrations_table_name
  end
end