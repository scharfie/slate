ActiveRecord::Schema.define :version => 0 do
  create_table :collections, :force => true do |t|
    t.string :name
  end
  
  create_table :items, :force => true do |t|
    t.string :name
    t.integer :collection_id
    t.integer :position
  end
end