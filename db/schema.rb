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

ActiveRecord::Schema.define(version: 20141214172313) do

  create_table "accounts", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "forename"
    t.string   "surname"
    t.string   "matriculation_number"
    t.text     "options"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "admin"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "courses", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",      default: true
  end

  create_table "email_addresses", force: true do |t|
    t.string   "email"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_addresses", ["account_id"], name: "index_email_addresses_on_account_id", using: :btree

  create_table "evaluation_groups", force: true do |t|
    t.integer  "points"
    t.float    "percent"
    t.integer  "rating_group_id"
    t.integer  "submission_evaluation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluation_groups", ["rating_group_id"], name: "index_evaluation_groups_on_rating_group_id", using: :btree
  add_index "evaluation_groups", ["submission_evaluation_id"], name: "index_evaluation_groups_on_submission_evaluation_id", using: :btree

  create_table "evaluations", force: true do |t|
    t.boolean  "checked"
    t.integer  "value"
    t.integer  "rating_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "evaluation_group_id"
    t.boolean  "checked_automatically"
  end

  add_index "evaluations", ["evaluation_group_id"], name: "index_evaluations_on_evaluation_group_id", using: :btree
  add_index "evaluations", ["rating_id"], name: "index_evaluations_on_rating_id", using: :btree

  create_table "exercise_registrations", force: true do |t|
    t.integer  "exercise_id"
    t.integer  "term_registration_id"
    t.integer  "submission_id"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exercise_registrations", ["exercise_id"], name: "index_exercise_registrations_on_exercise_id", using: :btree
  add_index "exercise_registrations", ["submission_id"], name: "index_exercise_registrations_on_submission_id", using: :btree
  add_index "exercise_registrations", ["term_registration_id"], name: "index_exercise_registrations_on_term_registration_id", using: :btree

  create_table "exercises", force: true do |t|
    t.integer  "term_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.datetime "deadline"
    t.datetime "late_deadline"
    t.boolean  "enable_max_total_points"
    t.integer  "max_total_points"
    t.integer  "row_order"
    t.boolean  "group_submission"
    t.integer  "points"
    t.boolean  "enable_min_required_points"
    t.integer  "min_required_points"
    t.string   "submission_viewer_identifier"
    t.boolean  "allow_student_uploads"
    t.integer  "maximum_upload_size"
    t.boolean  "enable_student_uploads",       default: true
    t.boolean  "enable_max_upload_size"
    t.integer  "visible_points"
  end

  add_index "exercises", ["term_id"], name: "index_exercises_on_term_id", using: :btree

  create_table "exports", force: true do |t|
    t.string   "type"
    t.integer  "status"
    t.integer  "term_id"
    t.string   "file"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exports", ["term_id"], name: "index_exports_on_term_id", using: :btree

  create_table "import_student_imports", force: true do |t|
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file"
    t.string   "format"
    t.string   "status"
    t.integer  "line_count"
    t.text     "import_options"
    t.text     "import_mapping"
    t.text     "import_result"
  end

  add_index "import_student_imports", ["term_id"], name: "index_import_student_imports_on_term_id", using: :btree

  create_table "lecturer_registrations", force: true do |t|
    t.integer  "account_id"
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lecturer_registrations", ["account_id"], name: "index_lecturer_registrations_on_account_id", using: :btree
  add_index "lecturer_registrations", ["term_id"], name: "index_lecturer_registrations_on_term_id", using: :btree

  create_table "rating_groups", force: true do |t|
    t.integer  "exercise_id"
    t.string   "title"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.boolean  "global"
    t.integer  "min_points"
    t.integer  "max_points"
    t.boolean  "enable_range_points"
    t.integer  "row_order"
  end

  add_index "rating_groups", ["exercise_id"], name: "index_rating_groups_on_exercise_id", using: :btree

  create_table "ratings", force: true do |t|
    t.integer  "rating_group_id"
    t.string   "title"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "type"
    t.integer  "max_value"
    t.integer  "min_value"
    t.integer  "row_order"
    t.float    "multiplication_factor"
    t.string   "automated_checker_identifier"
  end

  add_index "ratings", ["rating_group_id"], name: "index_ratings_on_rating_group_id", using: :btree

  create_table "result_publications", force: true do |t|
    t.integer  "exercise_id"
    t.integer  "tutorial_group_id"
    t.boolean  "published",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "result_publications", ["exercise_id"], name: "index_result_publications_on_exercise_id", using: :btree
  add_index "result_publications", ["tutorial_group_id"], name: "index_result_publications_on_tutorial_group_id", using: :btree

  create_table "services", force: true do |t|
    t.integer  "exercise_id"
    t.boolean  "active",      default: false
    t.string   "type"
    t.text     "properties"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_group_registrations", force: true do |t|
    t.integer  "exercise_id"
    t.integer  "student_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "student_group_registrations", ["exercise_id"], name: "index_student_group_registrations_on_exercise_id", using: :btree
  add_index "student_group_registrations", ["student_group_id"], name: "index_student_group_registrations_on_student_group_id", using: :btree

  create_table "student_groups", force: true do |t|
    t.string   "title"
    t.integer  "tutorial_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "solitary"
    t.integer  "points"
    t.boolean  "active",            default: true
    t.string   "topic_identifier"
  end

  add_index "student_groups", ["tutorial_group_id"], name: "index_student_groups_on_tutorial_group_id", using: :btree

  create_table "student_registrations", force: true do |t|
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.integer  "student_group_id"
  end

  add_index "student_registrations", ["account_id"], name: "index_student_registrations_on_account_id", using: :btree
  add_index "student_registrations", ["student_group_id"], name: "index_student_registrations_on_student_group_id", using: :btree

  create_table "submission_assets", force: true do |t|
    t.integer  "submission_id"
    t.string   "file"
    t.string   "content_type"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_identifier"
    t.string   "import_identifier"
  end

  add_index "submission_assets", ["submission_id"], name: "index_submission_assets_on_submission_id", using: :btree

  create_table "submission_evaluations", force: true do |t|
    t.integer  "submission_id"
    t.integer  "evaluator_id"
    t.string   "evaluator_type"
    t.datetime "evaluated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evaluation_result"
    t.boolean  "plagiarized"
  end

  add_index "submission_evaluations", ["evaluator_id"], name: "index_submission_evaluations_on_evaluator_id", using: :btree
  add_index "submission_evaluations", ["submission_id"], name: "index_submission_evaluations_on_submission_id", using: :btree

  create_table "submissions", force: true do |t|
    t.integer  "exercise_id"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_group_registration_id"
    t.integer  "submitter_id"
  end

  add_index "submissions", ["exercise_id"], name: "index_submissions_on_exercise_id", using: :btree
  add_index "submissions", ["student_group_registration_id"], name: "index_submissions_on_student_group_registration_id", using: :btree
  add_index "submissions", ["submitter_id"], name: "index_submissions_on_submitter_id", using: :btree

  create_table "term_registrations", force: true do |t|
    t.string   "role"
    t.integer  "points"
    t.boolean  "positive_grade",    default: false, null: false
    t.integer  "account_id"
    t.integer  "term_id"
    t.integer  "tutorial_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "receives_grade"
  end

  add_index "term_registrations", ["account_id"], name: "index_term_registrations_on_account_id", using: :btree
  add_index "term_registrations", ["term_id"], name: "index_term_registrations_on_term_id", using: :btree
  add_index "term_registrations", ["tutorial_group_id"], name: "index_term_registrations_on_tutorial_group_id", using: :btree

  create_table "terms", force: true do |t|
    t.string   "title"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "row_order"
    t.text     "grading_scale"
    t.integer  "points"
  end

  add_index "terms", ["course_id"], name: "index_terms_on_course_id", using: :btree

  create_table "tutor_registrations", force: true do |t|
    t.integer  "account_id"
    t.integer  "tutorial_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tutor_registrations", ["account_id"], name: "index_tutor_registrations_on_account_id", using: :btree
  add_index "tutor_registrations", ["tutorial_group_id"], name: "index_tutor_registrations_on_tutorial_group_id", using: :btree

  create_table "tutorial_groups", force: true do |t|
    t.string   "title"
    t.integer  "term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  add_index "tutorial_groups", ["term_id"], name: "index_tutorial_groups_on_term_id", using: :btree

end
