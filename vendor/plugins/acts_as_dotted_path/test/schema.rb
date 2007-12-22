ActiveRecord::Schema.define :version => 0 do
  create_table :pages, :force => true do |t|
    t.column :name, :string
    t.column :path, :string, :default => ''
    t.column :parent_id, :integer
    t.column :depth, :integer, :default => 0
    t.column :site_id, :integer
    t.column :other_id, :integer # for testing custom scope
    t.column :position, :integer, :default => 0
    t.column :children_count, :integer, :default => 0
  end
  
  create_table :sites, :force => true do |t|
    t.column :name, :string
  end
end