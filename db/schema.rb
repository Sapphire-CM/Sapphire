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

ActiveRecord::Schema.define(:version => 20121221122215) do

  create_table "students", :force => true do |t|
    t.integer  "tutorial_group_id"
    t.integer  "submission_group_id"
    t.string   "forename"
    t.string   "surname"
    t.integer  "matriculum_number"
    t.string   "email"
    t.datetime "registration_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "students", ["submission_group_id"], :name => "index_students_on_submission_group_id"
  add_index "students", ["tutorial_group_id"], :name => "index_students_on_tutorial_group_id"

end
