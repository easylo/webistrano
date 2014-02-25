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

ActiveRecord::Schema.define(:version => 20131017211742) do

  create_table "configuration_parameters", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "project_id"
    t.integer  "stage_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "prompt_on_deploy", :default => 0
    t.integer  "host_id"
    t.string   "description",      :default => ""
  end

  create_table "deployments", :force => true do |t|
    t.string   "task"
    t.text     "log",               :limit => 2147483647
    t.integer  "stage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "completed_at"
    t.text     "description"
    t.integer  "user_id"
    t.string   "excluded_host_ids"
    t.string   "revision"
    t.integer  "pid"
    t.string   "status",                                  :default => "running"
  end

  add_index "deployments", ["stage_id"], :name => "index_deployments_on_stage_id"
  add_index "deployments", ["user_id"], :name => "index_deployments_on_user_id"

  create_table "deployments_roles", :id => false, :force => true do |t|
    t.integer "deployment_id"
    t.integer "role_id"
  end

  add_index "deployments_roles", ["deployment_id", "role_id"], :name => "index_deployments_roles_on_deployment_id_and_role_id", :unique => true

  create_table "host_configurations", :force => true do |t|
  end

  create_table "hosts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alias",      :default => ""
  end

  create_table "project_configurations", :force => true do |t|
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "archived",    :default => false
  end

  create_table "projects_users", :id => false, :force => true do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id", "user_id"], :name => "index_projects_users_on_project_id_and_user_id", :unique => true

  create_table "recipe_versions", :force => true do |t|
    t.integer  "recipe_id"
    t.integer  "version"
    t.string   "name"
    t.text     "body"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recipes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version",     :default => 1
  end

  create_table "recipes_stages", :id => false, :force => true do |t|
    t.integer "recipe_id"
    t.integer "stage_id"
  end

  add_index "recipes_stages", ["recipe_id", "stage_id"], :name => "index_recipes_stages_on_recipe_id_and_stage_id", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "stage_id"
    t.integer  "host_id"
    t.integer  "primary",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "no_release", :default => 0
    t.integer  "ssh_port"
    t.integer  "no_symlink", :default => 0
  end

  add_index "roles", ["host_id"], :name => "index_roles_on_host_id"
  add_index "roles", ["stage_id"], :name => "index_roles_on_stage_id"

  create_table "stage_configurations", :force => true do |t|
  end

  create_table "stages", :force => true do |t|
    t.string   "name"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "alert_emails"
    t.integer  "locked_by_deployment_id"
    t.integer  "locked",                  :default => 0
  end

  add_index "stages", ["project_id"], :name => "index_stages_on_project_id"

  create_table "stages_users", :id => false, :force => true do |t|
    t.integer "stage_id"
    t.integer "user_id"
    t.boolean "read_only"
  end

  add_index "stages_users", ["stage_id", "user_id"], :name => "index_stages_users_on_stage_id_and_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "admin",                                   :default => 0
    t.string   "time_zone",                               :default => "UTC"
    t.datetime "disabled"
    t.string   "ldap_cn"
    t.integer  "dev"
  end

  add_index "users", ["disabled"], :name => "index_users_on_disabled"

end
