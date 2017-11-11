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

ActiveRecord::Schema.define(version: 20171106105320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "forename",               limit: 255
    t.string   "surname",                limit: 255
    t.string   "matriculation_number",   limit: 255
    t.text     "options"
    t.integer  "failed_attempts",                    default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.boolean  "admin",                              default: false, null: false
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["matriculation_number"], name: "index_accounts_on_matriculation_number", unique: true, using: :btree
  add_index "accounts", ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true, using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "locked",                  default: true, null: false
  end

  add_index "courses", ["title"], name: "index_courses_on_title", unique: true, using: :btree

  create_table "email_addresses", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.integer  "account_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "email_addresses", ["account_id"], name: "index_email_addresses_on_account_id", using: :btree
  add_index "email_addresses", ["email"], name: "index_email_addresses_on_email", unique: true, using: :btree

  create_table "evaluation_groups", force: :cascade do |t|
    t.integer  "points"
    t.float    "percent"
    t.integer  "rating_group_id"
    t.integer  "submission_evaluation_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "status",                   default: 0,     null: false
    t.boolean  "needs_review",             default: false
  end

  add_index "evaluation_groups", ["rating_group_id"], name: "index_evaluation_groups_on_rating_group_id", using: :btree
  add_index "evaluation_groups", ["submission_evaluation_id"], name: "index_evaluation_groups_on_submission_evaluation_id", using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.boolean  "checked",                           default: false, null: false
    t.integer  "rating_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "type",                  limit: 255
    t.integer  "value"
    t.integer  "evaluation_group_id"
    t.boolean  "checked_automatically",             default: false, null: false
    t.boolean  "needs_review",                      default: false
  end

  add_index "evaluations", ["evaluation_group_id"], name: "index_evaluations_on_evaluation_group_id", using: :btree
  add_index "evaluations", ["rating_id"], name: "index_evaluations_on_rating_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "type"
    t.integer  "subject_id",   null: false
    t.string   "subject_type", null: false
    t.integer  "account_id",   null: false
    t.integer  "term_id",      null: false
    t.text     "data"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "events", ["account_id"], name: "index_events_on_account_id", using: :btree
  add_index "events", ["subject_type", "subject_id"], name: "index_events_on_subject_type_and_subject_id", using: :btree

  create_table "exercise_registrations", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "term_registration_id"
    t.integer  "submission_id"
    t.integer  "points"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "exercise_registrations", ["exercise_id"], name: "index_exercise_registrations_on_exercise_id", using: :btree
  add_index "exercise_registrations", ["submission_id"], name: "index_exercise_registrations_on_submission_id", using: :btree
  add_index "exercise_registrations", ["term_registration_id"], name: "index_exercise_registrations_on_term_registration_id", using: :btree

  create_table "exercises", force: :cascade do |t|
    t.integer  "term_id"
    t.string   "title",                        limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.text     "description"
    t.datetime "deadline"
    t.datetime "late_deadline"
    t.boolean  "enable_max_total_points",                  default: false, null: false
    t.integer  "max_total_points"
    t.integer  "row_order"
    t.boolean  "group_submission",                         default: false, null: false
    t.integer  "points"
    t.boolean  "enable_min_required_points",               default: false, null: false
    t.integer  "min_required_points"
    t.string   "submission_viewer_identifier", limit: 255
    t.integer  "maximum_upload_size"
    t.boolean  "enable_student_uploads",                   default: true,  null: false
    t.boolean  "enable_max_upload_size",                   default: false, null: false
    t.integer  "visible_points"
    t.string   "instructions_url"
  end

  add_index "exercises", ["term_id"], name: "index_exercises_on_term_id", using: :btree
  add_index "exercises", ["title", "term_id"], name: "index_exercises_on_title_and_term_id", unique: true, using: :btree

  create_table "exports", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.integer  "status"
    t.integer  "term_id"
    t.string   "file",       limit: 255
    t.text     "properties"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "exports", ["term_id"], name: "index_exports_on_term_id", using: :btree

  create_table "grading_scales", force: :cascade do |t|
    t.integer  "term_id"
    t.string   "grade",                      null: false
    t.boolean  "not_graded", default: false, null: false
    t.boolean  "positive",   default: true,  null: false
    t.integer  "min_points", default: 0,     null: false
    t.integer  "max_points", default: 0,     null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "grading_scales", ["grade"], name: "index_grading_scales_on_grade", using: :btree
  add_index "grading_scales", ["term_id", "grade"], name: "index_grading_scales_on_term_id_and_grade", unique: true, using: :btree
  add_index "grading_scales", ["term_id"], name: "index_grading_scales_on_term_id", using: :btree

  create_table "import_errors", force: :cascade do |t|
    t.integer  "import_result_id"
    t.string   "row",              limit: 255
    t.string   "entry",            limit: 255
    t.string   "message",          limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "import_errors", ["import_result_id"], name: "index_import_errors_on_import_result_id", using: :btree

  create_table "import_mappings", force: :cascade do |t|
    t.integer  "import_id"
    t.integer  "group"
    t.integer  "email"
    t.integer  "forename"
    t.integer  "surname"
    t.integer  "matriculation_number"
    t.integer  "comment"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "import_mappings", ["import_id"], name: "index_import_mappings_on_import_id", unique: true, using: :btree

  create_table "import_options", force: :cascade do |t|
    t.integer  "import_id"
    t.integer  "matching_groups"
    t.string   "tutorial_groups_regexp",     limit: 255
    t.string   "student_groups_regexp",      limit: 255
    t.boolean  "headers_on_first_line",                  default: true, null: false
    t.string   "column_separator",           limit: 255
    t.string   "quote_char",                 limit: 255
    t.string   "decimal_separator",          limit: 255
    t.string   "thousands_separator",        limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "send_welcome_notifications",             default: true, null: false
  end

  add_index "import_options", ["import_id"], name: "index_import_options_on_import_id", unique: true, using: :btree

  create_table "import_results", force: :cascade do |t|
    t.integer  "import_id"
    t.boolean  "success",                     default: false, null: false
    t.boolean  "encoding_error",              default: false, null: false
    t.boolean  "parsing_error",               default: false, null: false
    t.integer  "total_rows"
    t.integer  "processed_rows"
    t.integer  "imported_students"
    t.integer  "imported_tutorial_groups"
    t.integer  "imported_term_registrations"
    t.integer  "imported_student_groups"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "import_results", ["import_id"], name: "index_import_results_on_import_id", unique: true, using: :btree

  create_table "imports", force: :cascade do |t|
    t.integer  "term_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "file",       limit: 255
    t.integer  "status"
  end

  add_index "imports", ["term_id"], name: "index_imports_on_term_id", using: :btree

  create_table "rating_groups", force: :cascade do |t|
    t.integer  "exercise_id"
    t.string   "title",               limit: 255
    t.integer  "points"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "description"
    t.boolean  "global",                          default: false, null: false
    t.integer  "min_points"
    t.integer  "max_points"
    t.boolean  "enable_range_points",             default: false, null: false
    t.integer  "row_order"
  end

  add_index "rating_groups", ["exercise_id"], name: "index_rating_groups_on_exercise_id", using: :btree
  add_index "rating_groups", ["title", "exercise_id"], name: "index_rating_groups_on_title_and_exercise_id", unique: true, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "rating_group_id"
    t.string   "title",                        limit: 255
    t.integer  "value"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "description"
    t.string   "type",                         limit: 255
    t.integer  "max_value"
    t.integer  "min_value"
    t.integer  "row_order"
    t.float    "multiplication_factor"
    t.string   "automated_checker_identifier", limit: 255
  end

  add_index "ratings", ["rating_group_id"], name: "index_ratings_on_rating_group_id", using: :btree

  create_table "result_publications", force: :cascade do |t|
    t.integer  "exercise_id"
    t.integer  "tutorial_group_id"
    t.boolean  "published",         default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "result_publications", ["exercise_id", "tutorial_group_id"], name: "index_result_publications_on_exercise_id_and_tutorial_group_id", unique: true, using: :btree
  add_index "result_publications", ["exercise_id"], name: "index_result_publications_on_exercise_id", using: :btree
  add_index "result_publications", ["tutorial_group_id"], name: "index_result_publications_on_tutorial_group_id", using: :btree

  create_table "services", force: :cascade do |t|
    t.integer  "exercise_id"
    t.boolean  "active",                  default: false, null: false
    t.string   "type",        limit: 255
    t.text     "properties"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "student_groups", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.integer  "tutorial_group_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "points"
    t.string   "keyword"
    t.string   "topic"
    t.text     "description"
  end

  add_index "student_groups", ["tutorial_group_id"], name: "index_student_groups_on_tutorial_group_id", using: :btree

  create_table "submission_assets", force: :cascade do |t|
    t.integer  "submission_id"
    t.string   "file",              limit: 255
    t.string   "content_type",      limit: 255
    t.datetime "submitted_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "asset_identifier",  limit: 255
    t.string   "import_identifier", limit: 255
    t.string   "path",                          default: ""
    t.string   "filename"
    t.integer  "processed_size",                default: 0
    t.integer  "filesystem_size",               default: 0
    t.integer  "extraction_status"
  end

  add_index "submission_assets", ["filename", "path", "submission_id"], name: "index_submission_assets_on_filename_and_path_and_submission_id", unique: true, using: :btree
  add_index "submission_assets", ["submission_id"], name: "index_submission_assets_on_submission_id", using: :btree

  create_table "submission_evaluations", force: :cascade do |t|
    t.integer  "submission_id"
    t.integer  "evaluator_id"
    t.string   "evaluator_type",    limit: 255
    t.datetime "evaluated_at"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "evaluation_result"
    t.boolean  "plagiarized",                   default: false, null: false
    t.boolean  "needs_review",                  default: false
  end

  add_index "submission_evaluations", ["evaluator_id"], name: "index_submission_evaluations_on_evaluator_id", using: :btree
  add_index "submission_evaluations", ["submission_id"], name: "index_submission_evaluations_on_submission_id", unique: true, using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "exercise_id"
    t.datetime "submitted_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "submitter_id"
    t.integer  "student_group_id"
    t.boolean  "outdated",         default: false, null: false
  end

  add_index "submissions", ["exercise_id"], name: "index_submissions_on_exercise_id", using: :btree
  add_index "submissions", ["student_group_id"], name: "index_submissions_on_student_group_id", using: :btree
  add_index "submissions", ["submitter_id"], name: "index_submissions_on_submitter_id", using: :btree

  create_table "term_registrations", force: :cascade do |t|
    t.integer  "points"
    t.boolean  "positive_grade",    default: false, null: false
    t.integer  "account_id"
    t.integer  "term_id"
    t.integer  "tutorial_group_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "receives_grade",    default: false, null: false
    t.integer  "role",              default: 0
    t.integer  "student_group_id"
  end

  add_index "term_registrations", ["account_id", "term_id"], name: "index_term_registrations_on_account_id_and_term_id", unique: true, using: :btree
  add_index "term_registrations", ["account_id"], name: "index_term_registrations_on_account_id", using: :btree
  add_index "term_registrations", ["student_group_id"], name: "index_term_registrations_on_student_group_id", using: :btree
  add_index "term_registrations", ["term_id"], name: "index_term_registrations_on_term_id", using: :btree
  add_index "term_registrations", ["tutorial_group_id"], name: "index_term_registrations_on_tutorial_group_id", using: :btree

  create_table "terms", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.integer  "course_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "description"
    t.integer  "row_order"
    t.integer  "points",                  default: 0
    t.integer  "status",                  default: 0
  end

  add_index "terms", ["course_id"], name: "index_terms_on_course_id", using: :btree
  add_index "terms", ["title", "course_id"], name: "index_terms_on_title_and_course_id", unique: true, using: :btree

  create_table "tutorial_groups", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.integer  "term_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.text     "description"
  end

  add_index "tutorial_groups", ["term_id"], name: "index_tutorial_groups_on_term_id", using: :btree
  add_index "tutorial_groups", ["title", "term_id"], name: "index_tutorial_groups_on_title_and_term_id", unique: true, using: :btree

  add_foreign_key "events", "accounts"
  add_foreign_key "events", "terms"
end
