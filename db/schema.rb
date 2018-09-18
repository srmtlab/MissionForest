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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180917104214) do

  create_table "mission_admins", force: :cascade do |t|
    t.integer  "mission_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "mission_participants", force: :cascade do |t|
    t.integer  "mission_id", limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "missions", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "missions", ["user_id"], name: "index_missions_on_user_id", using: :btree

  create_table "task_participants", force: :cascade do |t|
    t.integer  "task_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "task_participants", ["task_id"], name: "index_task_participants_on_task_id", using: :btree
  add_index "task_participants", ["user_id"], name: "index_task_participants_on_user_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "mission_id",        limit: 4
    t.string   "title",             limit: 255
    t.text     "description",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deadline_at"
    t.integer  "status",            limit: 4,     default: 0
    t.integer  "sub_task_of",       limit: 4
    t.integer  "direct_mission_id", limit: 4
    t.integer  "notify",            limit: 4,     default: 0
  end

  add_index "tasks", ["mission_id"], name: "index_tasks_on_mission_id", using: :btree
  add_index "tasks", ["sub_task_of"], name: "index_tasks_on_sub_task_of", using: :btree
  add_index "tasks", ["user_id"], name: "index_tasks_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: 255
    t.integer  "participation_id",       limit: 4
    t.string   "authentication_token",   limit: 255
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["participation_id"], name: "index_users_on_participation_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "task_participants", "tasks"
  add_foreign_key "task_participants", "users"
end
