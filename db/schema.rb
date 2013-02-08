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

ActiveRecord::Schema.define(:version => 20130208083338) do

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "course_leader_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "courses", ["course_leader_id"], :name => "index_courses_on_course_leader_id"

  create_table "exercises", :force => true do |t|
    t.integer  "term_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
  end

  add_index "exercises", ["term_id"], :name => "index_exercises_on_term_id"

  create_table "import_student_imports", :force => true do |t|
    t.integer  "term_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "file"
    t.string   "format"
    t.string   "status"
    t.integer  "line_count"
    t.text     "import_options"
    t.text     "import_mapping"
  end

  add_index "import_student_imports", ["term_id"], :name => "index_import_student_imports_on_semester_id"

  create_table "rating_groups", :force => true do |t|
    t.integer  "exercise_id"
    t.string   "title"
    t.integer  "points"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "rating_groups", ["exercise_id"], :name => "index_rating_groups_on_exercise_id"

  create_table "ratings", :force => true do |t|
    t.integer  "rating_group_id"
    t.string   "title"
    t.integer  "points"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "ratings", ["rating_group_id"], :name => "index_ratings_on_rating_group_id"

  create_table "students", :force => true do |t|
    t.string   "forename"
    t.string   "surname"
    t.string   "matriculum_number"
    t.string   "email"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "term_registrations", :force => true do |t|
    t.datetime "registered_at"
    t.integer  "tutorial_group_id"
    t.integer  "term_id"
    t.integer  "student_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "term_registrations", ["student_id"], :name => "index_term_registrations_on_student_id"
  add_index "term_registrations", ["term_id"], :name => "index_term_registrations_on_term_id"
  add_index "term_registrations", ["tutorial_group_id"], :name => "index_term_registrations_on_tutorial_group_id"

  create_table "terms", :force => true do |t|
    t.string   "title"
    t.boolean  "active"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "terms", ["course_id"], :name => "index_terms_on_course_id"

  create_table "tutorial_groups", :force => true do |t|
    t.string   "title"
    t.integer  "term_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tutorial_groups", ["term_id"], :name => "index_tutorial_groups_on_term_id"

end
