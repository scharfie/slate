class AddVersioningToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :area_id, :integer
    add_column :areas, :version, :integer, :default => 0
  end

  def self.down
    remove_column :areas, :area_id
    remove_column :areas, :version
  end
end
