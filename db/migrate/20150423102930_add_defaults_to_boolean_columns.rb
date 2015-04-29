class AddDefaultsToBooleanColumns < ActiveRecord::Migration
  def up
    change_column :evaluations,            :checked,                    :boolean, null: false, default: false
    change_column :evaluations,            :checked_automatically,      :boolean, null: false, default: false
    change_column :exercises,              :enable_max_total_points,    :boolean, null: false, default: false
    change_column :exercises,              :group_submission,           :boolean, null: false, default: false
    change_column :exercises,              :enable_min_required_points, :boolean, null: false, default: false
    change_column :exercises,              :enable_max_upload_size,     :boolean, null: false, default: false
    change_column :rating_groups,          :global,                     :boolean, null: false, default: false
    change_column :rating_groups,          :enable_range_points,        :boolean, null: false, default: false
    change_column :submission_evaluations, :plagiarized,                :boolean, null: false, default: false
    change_column :term_registrations,     :receives_grade,             :boolean, null: false, default: false

    change_column_null :accounts,            :admin,                      false
    change_column_null :courses,             :locked,                     false
    change_column_null :exercises,           :enable_student_uploads,     false
    change_column_null :import_options,      :headers_on_first_line,      false
    change_column_null :import_options,      :send_welcome_notifications, false
    change_column_null :import_results,      :success,                    false
    change_column_null :import_results,      :encoding_error,             false
    change_column_null :import_results,      :parsing_error,              false
    change_column_null :result_publications, :published,                  false
    change_column_null :services,            :active,                     false
  end

  def down
    change_column :evaluations,            :checked,                    :boolean, null: nil, default: nil
    change_column :evaluations,            :checked_automatically,      :boolean, null: nil, default: nil
    change_column :exercises,              :enable_max_total_points,    :boolean, null: nil, default: nil
    change_column :exercises,              :group_submission,           :boolean, null: nil, default: nil
    change_column :exercises,              :enable_min_required_points, :boolean, null: nil, default: nil
    change_column :exercises,              :enable_max_upload_size,     :boolean, null: nil, default: nil
    change_column :rating_groups,          :global,                     :boolean, null: nil, default: nil
    change_column :rating_groups,          :enable_range_points,        :boolean, null: nil, default: nil
    change_column :submission_evaluations, :plagiarized,                :boolean, null: nil, default: nil
    change_column :term_registrations,     :receives_grade,             :boolean, null: nil, default: nil

    change_column_null :accounts,            :admin,                      true
    change_column_null :courses,             :locked,                     true
    change_column_null :exercises,           :enable_student_uploads,     true
    change_column_null :import_options,      :headers_on_first_line,      true
    change_column_null :import_options,      :send_welcome_notifications, true
    change_column_null :import_results,      :success,                    true
    change_column_null :import_results,      :encoding_error,             true
    change_column_null :import_results,      :parsing_error,              true
    change_column_null :result_publications, :published,                  true
    change_column_null :services,            :active,                     true
  end
end
