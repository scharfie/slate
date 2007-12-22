class AddPublishedOnToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :published_on, :datetime
  end

  def self.down
    remove_column :areas, :published_on
  end
end
