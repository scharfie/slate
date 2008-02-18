class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :name, :string
      t.column :parent_id, :integer, :default => 0
      t.column :space_id, :integer
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      t.column :path, :string
      t.column :depth, :integer
      t.column :permalink, :string
      t.column :template, :string
      t.column :position, :integer, :default => 9999
      t.column :is_hidden, :boolean, :default => false
      t.column :is_default, :boolean, :default => false
      t.column :children_count, :integer, :default => 0
    end
  end

  def self.down
    drop_table :pages
  end
end
