class CreateAreas < ActiveRecord::Migration
  def self.up
    create_table :areas do |t|
      t.column "key",         :string
      t.column "page_id",     :integer
      t.column "body",        :text
      t.column "body_html",   :text
      t.column "hard_breaks", :boolean,  :default => true
      t.column "is_default",  :boolean
      t.column "created_on",  :datetime
      t.column "updated_on",  :datetime
      t.column "user_id",     :integer
    end
  end

  def self.down
    drop_table :areas
  end
end
