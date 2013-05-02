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

ActiveRecord::Schema.define(:version => 20130502114026) do

  create_table "accounts", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "forename"
    t.string   "surname"
    t.string   "matriculum_number"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["reset_password_token"], :name => "index_accounts_on_reset_password_token", :unique => true

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "evaluations", :force => true do |t|
    t.boolean  "checked"
    t.integer  "rating_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "type"
    t.integer  "value"
    t.integer  "submission_evaluation_id"
  end

  add_index "evaluations", ["rating_id"], :name => "index_evaluations_on_rating_id"
  add_index "evaluations", ["submission_evaluation_id"], :name => "index_evaluations_on_submission_evaluation_id"

  create_table "exercises", :force => true do |t|
    t.integer  "term_id"
    t.string   "title"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "description"
    t.datetime "deadline"
    t.datetime "late_deadline"
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

  create_table "lecturer_registrations", :force => true do |t|
    t.integer  "account_id"
    t.integer  "term_id"
    t.datetime "registered_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "lecturer_registrations", ["account_id"], :name => "index_lecturer_term_registrations_on_account_id"
  add_index "lecturer_registrations", ["term_id"], :name => "index_lecturer_term_registrations_on_term_id"

  create_table "rating_groups", :force => true do |t|
    t.integer  "exercise_id"
    t.string   "title"
    t.integer  "points"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
    t.boolean  "global"
    t.integer  "min_points"
    t.integer  "max_points"
  end

  add_index "rating_groups", ["exercise_id"], :name => "index_rating_groups_on_exercise_id"

  create_table "ratings", :force => true do |t|
    t.integer  "rating_group_id"
    t.string   "title"
    t.integer  "value"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.text     "description"
    t.string   "type"
    t.integer  "max_value"
    t.integer  "min_value"
  end

  add_index "ratings", ["rating_group_id"], :name => "index_ratings_on_rating_group_id"

  create_table "student_registrations", :force => true do |t|
    t.integer  "account_id"
    t.integer  "tutorial_group_id"
    t.datetime "registered_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "student_registrations", ["account_id"], :name => "index_student_term_registrations_on_account_id"
  add_index "student_registrations", ["tutorial_group_id"], :name => "index_student_term_registrations_on_tutorial_group_id"

  create_table "submission_evaluations", :force => true do |t|
    t.integer  "submission_id"
    t.integer  "evaluator_id"
    t.string   "evaluator_type"
    t.datetime "evaluated_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "evaluation_result"
  end

  add_index "submission_evaluations", ["evaluator_id"], :name => "index_submission_evaluations_on_evaluator_id"
  add_index "submission_evaluations", ["submission_id"], :name => "index_submission_evaluations_on_submission_id"

  create_table "submissions", :force => true do |t|
    t.integer  "exercise_id"
    t.integer  "student_registration_id"
    t.datetime "submitted_at"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "submissions", ["exercise_id"], :name => "index_submissions_on_exercise_id"
  add_index "submissions", ["student_registration_id"], :name => "index_submissions_on_student_registration_id"

  create_table "terms", :force => true do |t|
    t.string   "title"
    t.integer  "course_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  add_index "terms", ["course_id"], :name => "index_terms_on_course_id"

  create_table "tutor_registrations", :force => true do |t|
    t.integer  "account_id"
    t.integer  "tutorial_group_id"
    t.datetime "registered_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "tutor_registrations", ["account_id"], :name => "index_tutor_term_registrations_on_account_id"
  add_index "tutor_registrations", ["tutorial_group_id"], :name => "index_tutor_term_registrations_on_tutorial_group_id"

  create_table "tutorial_groups", :force => true do |t|
    t.string   "title"
    t.integer  "term_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
  end

  add_index "tutorial_groups", ["term_id"], :name => "index_tutorial_groups_on_term_id"

end
