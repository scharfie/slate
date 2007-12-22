class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
      t.column :user_id, :integer
      t.column :space_id, :integer
      t.column :role, :integer, :default => 1 # writer=0, publisher=1, admin=2
    end
  end

  def self.down
    drop_table :memberships
  end
end
