# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define do

  create_table "areas", :force => true do |t|
    t.string   "key"
    t.integer  "page_id"
    t.text     "body"
    t.text     "body_html"
    t.boolean  "hard_breaks",  :default => true
    t.boolean  "is_default"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.integer  "user_id"
    t.integer  "area_id"
    t.integer  "version",      :default => 0
    t.datetime "published_on"
  end

  create_table "articles", :force => true do |t|
    t.integer  "blog_id"
    t.string   "name"
    t.string   "permalink"
    t.text     "body"
    t.text     "body_html"
    t.datetime "published_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", :force => true do |t|
    t.string   "name"
    t.string   "filename"
    t.integer  "size"
    t.string   "content_type"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "space_id"
    t.datetime "created_on"
    t.datetime "updated_on"
  end

  create_table "blogs", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "space_id"
    t.integer "role",     :default => 1
  end

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id",      :default => 0
    t.integer  "space_id"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "path"
    t.integer  "depth"
    t.string   "template"
    t.integer  "position",       :default => 9999
    t.boolean  "is_hidden",      :default => false
    t.boolean  "is_default",     :default => false
    t.integer  "children_count", :default => 0
    t.string   "behavior_type"
    t.integer  "behavior_id"
  end
  
  create_table "permalinks", :force => true do |t|
    t.string  "name"
    t.string  "permalinkable_type"
    t.integer "permalinkable_id"
    t.boolean "is_default", :default => false
  end

  create_table "plugin_schema_info", :force => true do |t|
    t.string  "name"
    t.integer "version", :default => 0
    t.boolean "enabled", :default => true
  end

  create_table "plugins", :force => true do |t|
    t.string   "key"
    t.boolean  "enabled",    :default => true
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spaces", :force => true do |t|
    t.string "name"
    t.string "type"
    t.string "key"
    t.string "theme"
    t.string "google_analytics_code"
    t.text   "css"
  end

  create_table "users", :force => true do |t|
    t.string   "type"
    t.string   "username"
    t.string   "crypted_password"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "initial"
    t.string   "display_name"
    t.string   "telephone_number"
    t.string   "email_address"
    t.integer  "login_attempts",            :default => 0
    t.boolean  "locked",                    :default => false
    t.boolean  "super_user",                :default => false
    t.datetime "created_on"
    t.datetime "last_login"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
