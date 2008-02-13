class CreatePlugins < ActiveRecord::Migration
  def self.up
    create_table :plugins do |t|
      t.string :key
      t.boolean :enabled, :default => true
      t.integer :space_id
      t.timestamps
    end
  end

  def self.down
    drop_table :plugins
  end
end
