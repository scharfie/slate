class AddFormatToAreas < ActiveRecord::Migration
  def self.up
    add_column :areas, :format, :string
  end

  def self.down
    remove_column :areas, :format
  end
end
