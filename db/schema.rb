# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140123042113) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "audit_logs", :force => true do |t|
    t.string   "item_type"
    t.integer  "item_id"
    t.string   "item_attribute"
    t.string   "previous_value"
    t.string   "new_value"
    t.integer  "performed_by"
    t.datetime "created_at"
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "short_name"
    t.string   "long_name"
    t.text     "notes"
    t.string   "sas_group",              :limit => 11
    t.boolean  "capacity_enabled"
    t.boolean  "performance_enabled"
    t.boolean  "health_check_enabled"
    t.boolean  "oracle_enabled"
    t.boolean  "sql_enabled"
    t.boolean  "virtualization_enabled"
    t.string   "reference_url"
    t.string   "logo"
    t.string   "project_manager_email"
    t.string   "account_manager_email"
    t.string   "capacity_manager_email"
    t.string   "onboarded_by_email"
    t.string   "status"
  end

  create_table "clients_reporters", :force => true do |t|
    t.integer  "client_id"
    t.integer  "reporter_id"
    t.datetime "created_at"
    t.string   "reporter_group_cpm"
    t.string   "reporter_group_vmw"
    t.string   "reporter_group_sql"
    t.string   "reporter_group_ora"
  end

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.integer  "client_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "domains", ["client_id"], :name => "index_domains_on_client_id"

  create_table "reporters", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "port"
    t.string   "login"
    t.string   "password"
    t.string   "database_name"
    t.integer  "load_group"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "reporter_num"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,     :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "role_id"
    t.integer  "client_id"
    t.string   "status"
    t.integer  "failed_attempts",        :default => 0,     :null => false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "approved",               :default => false
    t.boolean  "disabled",               :default => false
  end

  add_index "users", ["client_id"], :name => "index_users_on_client_id"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["role_id"], :name => "index_users_on_role_id"

  create_table "versions", :force => true do |t|
    t.string   "item_type",      :null => false
    t.integer  "item_id",        :null => false
    t.string   "event",          :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "vw_cfgParamsDW", :force => true do |t|
    t.string "client_id"
    t.string "enableCM"
    t.string "enablePM"
    t.string "enableDB"
    t.string "enableVM"
    t.string "sasGroup"
    t.string "clientShortName"
    t.string "clientLongName"
    t.string "rptrID"
    t.string "rptrGroup"
    t.string "rptrGroupVM"
    t.string "rptrName"
    t.string "rptrIP"
    t.string "rptrPort"
    t.string "rptrLogin"
    t.string "rptrPass"
    t.string "rptrDB"
    t.string "loadGroup"
    t.string "config_parameter_id"
  end

end
