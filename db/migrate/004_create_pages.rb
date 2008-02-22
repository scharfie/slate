class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :name
      t.string :permalink
      t.integer :parent_id, :default => 0
      t.integer :space_id
      t.datetime :created_on
      t.datetime :updated_on
      t.string :template
      t.string :path
      t.integer :depth
      t.integer :position, :default => 9999
      t.boolean :is_hidden, :default => false
      t.boolean :is_default, :default => false
      t.integer :children_count, :default => 0
    end
  end

  def self.down
    drop_table :pages
  end
end
