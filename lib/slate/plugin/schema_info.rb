module Slate
  class Plugin
    class SchemaInfo < ActiveRecord::Base
      set_table_name 'plugin_schema_info'
      validates_presence_of :name
      validates_uniqueness_of :name
    end
  end
end