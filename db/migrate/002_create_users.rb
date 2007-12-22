class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :type, :string
      t.column :username, :string
      t.column :password, :string
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :initial, :string
      t.column :display_name, :string
      t.column :telephone_number, :string
      t.column :email_address, :string
      t.column :login_attempts, :integer, :default => 0
      t.column :locked, :boolean, :default => false
      t.column :super_user, :boolean, :default => false
      t.column :approved_by, :string
      t.column :approved_on, :datetime
      t.column :verified_on, :datetime
      t.column :requested_on, :datetime
      t.column :expires_on, :datetime
      t.column :created_on, :datetime
      t.column :last_login, :datetime
      t.column :reason_for_account, :text
    end
  end

  def self.down
    drop_table :users
  end
end
