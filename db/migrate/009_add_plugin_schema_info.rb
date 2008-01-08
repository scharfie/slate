class AddPluginSchemaInfo < ActiveRecord::Migration
  def self.up
    create_table 'plugin_schema_info', :force => true do |t|
      t.string :name
      t.integer :version, :default => 0
      t.boolean :enabled, :default => true
    end
  end

  def self.down
    drop_table 'plugin_schema_info'
  end
end
