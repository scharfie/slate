class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string  :name
      t.string  :filename
      t.integer :size
      t.string  :content_type
      t.integer :height
      t.integer :width
      t.integer :parent_id
      t.string  :thumbnail
      t.integer :space_id

      t.datetime :created_on
      t.datetime :updated_on
    end
  end

  def self.down
    drop_table :assets
  end
end
