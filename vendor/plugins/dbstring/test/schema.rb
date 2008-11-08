ActiveRecord::Schema.define :version => 0 do
  create_table :users, :force => true do |t|
    t.column :first_name, :string
    t.column :last_name, :string
    t.column :created_at, :datetime
  end  
end