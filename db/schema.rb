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

ActiveRecord::Schema.define(version: 20150223104307) do

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "forename",               limit: 255
    t.string   "surname",                limit: 255
    t.string   "matriculation_number",   limit: 255
    t.text     "options",                limit: 65535
    t.integer  "failed_attempts",        limit: 4,     default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.boolean  "admin",                  limit: 1,     default: false
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["matriculation_number"], name: "index_accounts_on_matriculation_number", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "locked",      limit: 1,     default: true
  end

  add_index "courses", ["title"], name: "index_courses_on_title", unique: true, using: :btree

  create_table "email_addresses", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.integer  "account_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "email_addresses", ["account_id"], name: "index_email_addresses_on_account_id", using: :btree
  add_index "email_addresses", ["email"], name: "index_email_addresses_on_email", unique: true, using: :btree

  create_table "evaluation_groups", force: :cascade do |t|
    t.integer  "points",                   limit: 4
    t.float    "percent",                  limit: 24
    t.integer  "rating_group_id",          limit: 4
    t.integer  "submission_evaluation_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "evaluation_groups", ["rating_group_id"], name: "index_evaluation_groups_on_rating_group_id", using: :btree
  add_index "evaluation_groups", ["submission_evaluation_id"], name: "index_evaluation_groups_on_submission_evaluation_id", using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.boolean  "checked",               limit: 1
    t.integer  "rating_id",             limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "type",                  limit: 255
    t.integer  "value",                 limit: 4
    t.integer  "evaluation_group_id",   limit: 4
    t.boolean  "checked_automatically", limit: 1
  end

  add_index "evaluations", ["evaluation_group_id"], name: "index_evaluations_on_evaluation_group_id", using: :btree
  add_index "evaluations", ["rating_id"], name: "index_evaluations_on_rating_id", using: :btree

  create_table "exercise_registrations", force: :cascade do |t|
    t.integer  "exercise_id",          limit: 4
    t.integer  "term_registration_id", limit: 4
    t.integer  "submission_id",        limit: 4
    t.integer  "points",               limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "exercise_registrations", ["exercise_id"], name: "index_exercise_registrations_on_exercise_id", using: :btree
  add_index "exercise_registrations", ["submission_id"], name: "index_exercise_registrations_on_submission_id", using: :btree
  add_index "exercise_registrations", ["term_registration_id"], name: "index_exercise_registrations_on_term_registration_id", using: :btree

  create_table "exercises", force: :cascade do |t|
    t.integer  "term_id",                      limit: 4
    t.string   "title",                        limit: 255
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.text     "description",                  limit: 65535
    t.datetime "deadline"
    t.datetime "late_deadline"
    t.boolean  "enable_max_total_points",      limit: 1
    t.integer  "max_total_points",             limit: 4
    t.integer  "row_order",                    limit: 4
    t.boolean  "group_submission",             limit: 1
    t.integer  "points",                       limit: 4
    t.boolean  "enable_min_required_points",   limit: 1
    t.integer  "min_required_points",          limit: 4
    t.string   "submission_viewer_identifier", limit: 255
    t.boolean  "allow_student_uploads",        limit: 1
    t.integer  "maximum_upload_size",          limit: 4
    t.boolean  "enable_student_uploads",       limit: 1,     default: true
    t.boolean  "enable_max_upload_size",       limit: 1
    t.integer  "visible_points",               limit: 4
  end

  add_index "exercises", ["term_id"], name: "index_exercises_on_term_id", using: :btree
  add_index "exercises", ["title", "term_id"], name: "index_exercises_on_title_and_term_id", unique: true, using: :btree

  create_table "exports", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.integer  "status",     limit: 4
    t.integer  "term_id",    limit: 4
    t.string   "file",       limit: 255
    t.text     "properties", limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "exports", ["term_id"], name: "index_exports_on_term_id", using: :btree

  create_table "import_errors", force: :cascade do |t|
    t.integer  "import_result_id", limit: 4
    t.string   "row",              limit: 255
    t.string   "entry",            limit: 255
    t.string   "message",          limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "import_errors", ["import_result_id"], name: "index_import_errors_on_import_result_id", using: :btree

  create_table "import_mappings", force: :cascade do |t|
    t.integer  "import_id",            limit: 4
    t.integer  "group",                limit: 4
    t.integer  "email",                limit: 4
    t.integer  "forename",             limit: 4
    t.integer  "surname",              limit: 4
    t.integer  "matriculation_number", limit: 4
    t.integer  "comment",              limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "import_mappings", ["import_id"], name: "index_import_mappings_on_import_id", unique: true, using: :btree

  create_table "import_options", force: :cascade do |t|
    t.integer  "import_id",              limit: 4
    t.integer  "matching_groups",        limit: 4
    t.string   "tutorial_groups_regexp", limit: 255
    t.string   "student_groups_regexp",  limit: 255
    t.boolean  "headers_on_first_line",  limit: 1,   default: true
    t.string   "column_separator",       limit: 255
    t.string   "quote_char",             limit: 255
    t.string   "decimal_separator",      limit: 255
    t.string   "thousands_separator",    limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "import_options", ["import_id"], name: "index_import_options_on_import_id", unique: true, using: :btree

  create_table "import_results", force: :cascade do |t|
    t.integer  "import_id",                      limit: 4
    t.boolean  "success",                        limit: 1, default: false
    t.boolean  "encoding_error",                 limit: 1, default: false
    t.boolean  "parsing_error",                  limit: 1, default: false
    t.integer  "total_rows",                     limit: 4
    t.integer  "processed_rows",                 limit: 4
    t.integer  "imported_students",              limit: 4
    t.integer  "imported_tutorial_groups",       limit: 4
    t.integer  "imported_term_registrations",    limit: 4
    t.integer  "imported_student_groups",        limit: 4
    t.integer  "imported_student_registrations", limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "import_results", ["import_id"], name: "index_import_results_on_import_id", unique: true, using: :btree

  create_table "import_student_imports", force: :cascade do |t|
    t.integer  "semester_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "file",        limit: 255
    t.string   "format",      limit: 255
  end

  add_index "import_student_imports", ["semester_id"], name: "index_import_student_imports_on_semester_id", using: :btree

  create_table "imports", force: :cascade do |t|
    t.integer  "term_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "file",       limit: 255
    t.integer  "status",     limit: 4
  end

  add_index "imports", ["term_id"], name: "index_imports_on_term_id", using: :btree

  create_table "lecturer_registrations", force: :cascade do |t|
    t.integer  "account_id", limit: 4
    t.integer  "term_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "lecturer_registrations", ["account_id"], name: "index_lecturer_registrations_on_account_id", using: :btree
  add_index "lecturer_registrations", ["term_id"], name: "index_lecturer_registrations_on_term_id", unique: true, using: :btree

  create_table "rating_groups", force: :cascade do |t|
    t.integer  "exercise_id",         limit: 4
    t.string   "title",               limit: 255
    t.integer  "points",              limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "description",         limit: 65535
    t.boolean  "global",              limit: 1
    t.integer  "min_points",          limit: 4
    t.integer  "max_points",          limit: 4
    t.boolean  "enable_range_points", limit: 1
    t.integer  "row_order",           limit: 4
  end

  add_index "rating_groups", ["exercise_id"], name: "index_rating_groups_on_exercise_id", using: :btree
  add_index "rating_groups", ["title", "exercise_id"], name: "index_rating_groups_on_title_and_exercise_id", unique: true, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating_group_id",              limit: 4
    t.string   "title",                        limit: 255
    t.integer  "value",                        limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "description",                  limit: 65535
    t.string   "type",                         limit: 255
    t.integer  "max_value",                    limit: 4
    t.integer  "min_value",                    limit: 4
    t.integer  "row_order",                    limit: 4
    t.float    "multiplication_factor",        limit: 24
    t.string   "automated_checker_identifier", limit: 255
  end

  add_index "ratings", ["rating_group_id"], name: "index_ratings_on_rating_group_id", using: :btree

  create_table "result_publications", force: :cascade do |t|
    t.integer  "exercise_id",       limit: 4
    t.integer  "tutorial_group_id", limit: 4
    t.boolean  "published",         limit: 1, default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "result_publications", ["exercise_id", "tutorial_group_id"], name: "index_result_publications_on_exercise_id_and_tutorial_group_id", unique: true, using: :btree
  add_index "result_publications", ["exercise_id"], name: "index_result_publications_on_exercise_id", using: :btree
  add_index "result_publications", ["tutorial_group_id"], name: "index_result_publications_on_tutorial_group_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "exercise_id", limit: 4
    t.boolean  "active",      limit: 1,     default: false
    t.string   "type",        limit: 255
    t.text     "properties",  limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "student_groups", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.integer  "tutorial_group_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "student_groups", ["tutorial_group_id"], name: "index_student_groups_on_tutorial_group_id", using: :btree

  create_table "student_registrations", force: :cascade do |t|
    t.integer  "account_id",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "comment",          limit: 255
    t.integer  "student_group_id", limit: 4
  end

  add_index "student_registrations", ["account_id"], name: "index_student_registrations_on_account_id", using: :btree
  add_index "student_registrations", ["student_group_id"], name: "index_student_registrations_on_student_group_id", using: :btree

  create_table "students", force: :cascade do |t|
    t.integer  "tutorial_group_id",   limit: 4
    t.integer  "submission_group_id", limit: 4
    t.string   "forename",            limit: 255
    t.string   "surname",             limit: 255
    t.integer  "matriculum_number",   limit: 4
    t.string   "email",               limit: 255
    t.datetime "registration_date"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "students", ["submission_group_id"], name: "index_students_on_submission_group_id", using: :btree
  add_index "students", ["tutorial_group_id"], name: "index_students_on_tutorial_group_id", using: :btree

  create_table "submission_assets", force: :cascade do |t|
    t.integer  "submission_id",     limit: 4
    t.string   "file",              limit: 255
    t.string   "content_type",      limit: 255
    t.datetime "submitted_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "asset_identifier",  limit: 255
    t.string   "import_identifier", limit: 255
  end

  add_index "submission_assets", ["submission_id"], name: "index_submission_assets_on_submission_id", using: :btree

  create_table "submission_evaluations", force: :cascade do |t|
    t.integer  "submission_id",     limit: 4
    t.integer  "evaluator_id",      limit: 4
    t.string   "evaluator_type",    limit: 255
    t.datetime "evaluated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "evaluation_result", limit: 4
    t.boolean  "plagiarized",       limit: 1
  end

  add_index "submission_evaluations", ["evaluator_id"], name: "index_submission_evaluations_on_evaluator_id", using: :btree
  add_index "submission_evaluations", ["submission_id"], name: "index_submission_evaluations_on_submission_id", unique: true, using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "exercise_id",                   limit: 4
    t.datetime "submitted_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "student_group_registration_id", limit: 4
    t.integer  "submitter_id",                  limit: 4
    t.integer  "student_group_id",              limit: 4
  end

  add_index "submissions", ["exercise_id"], name: "index_submissions_on_exercise_id", using: :btree
  add_index "submissions", ["student_group_id"], name: "index_submissions_on_student_group_id", using: :btree
  add_index "submissions", ["student_group_registration_id"], name: "index_submissions_on_student_group_registration_id", using: :btree
  add_index "submissions", ["submitter_id"], name: "index_submissions_on_submitter_id", using: :btree

  create_table "term_registrations", force: :cascade do |t|
    t.integer  "points",            limit: 4
    t.boolean  "positive_grade",    limit: 1, default: false, null: false
    t.integer  "account_id",        limit: 4
    t.integer  "term_id",           limit: 4
    t.integer  "tutorial_group_id", limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "receives_grade",    limit: 1
    t.integer  "role",              limit: 4, default: 0
    t.integer  "student_group_id",  limit: 4
  end

  add_index "term_registrations", ["account_id", "term_id"], name: "index_term_registrations_on_account_id_and_term_id", unique: true, using: :btree
  add_index "term_registrations", ["account_id"], name: "index_term_registrations_on_account_id", using: :btree
  add_index "term_registrations", ["student_group_id"], name: "index_term_registrations_on_student_group_id", using: :btree
  add_index "term_registrations", ["term_id"], name: "index_term_registrations_on_term_id", using: :btree
  add_index "term_registrations", ["tutorial_group_id"], name: "index_term_registrations_on_tutorial_group_id", using: :btree

  create_table "terms", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.integer  "course_id",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "description",   limit: 65535
    t.integer  "row_order",     limit: 4
    t.text     "grading_scale", limit: 65535
    t.integer  "points",        limit: 4
  end

  add_index "terms", ["course_id"], name: "index_terms_on_course_id", using: :btree
  add_index "terms", ["title", "course_id"], name: "index_terms_on_title_and_course_id", unique: true, using: :btree

  create_table "tutor_registrations", force: :cascade do |t|
    t.integer  "account_id",        limit: 4
    t.integer  "tutorial_group_id", limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "tutor_registrations", ["account_id"], name: "index_tutor_registrations_on_account_id", using: :btree
  add_index "tutor_registrations", ["tutorial_group_id"], name: "index_tutor_registrations_on_tutorial_group_id", using: :btree

  create_table "tutorial_groups", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.integer  "term_id",     limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "description", limit: 65535
  end

  add_index "tutorial_groups", ["term_id"], name: "index_tutorial_groups_on_term_id", using: :btree
  add_index "tutorial_groups", ["title", "term_id"], name: "index_tutorial_groups_on_title_and_term_id", unique: true, using: :btree

end
