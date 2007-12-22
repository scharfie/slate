class CreateSpaces < ActiveRecord::Migration
  def self.up
    create_table :spaces do |t|
      t.column :name, :string
      t.column :type, :string
      t.column :key, :string
      t.column :theme, :string
      t.column :domain, :string
      t.column :google_analytics_code, :string
      t.column :css, :text
    end
  end

  def self.down
    drop_table :spaces
  end
end
