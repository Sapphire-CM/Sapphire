class RemoveTutorialGroupIdSubmissionGroupIdAndRegistrationDateFromStudents < ActiveRecord::Migration
  def up
    remove_column :students, :tutorial_group_id
    remove_column :students, :submission_group_id
    remove_column :students, :registration_date
  end

  def down
    add_column :students, :registration_date, :datetime
    add_column :students, :submission_group_id, :integer
    add_column :students, :tutorial_group_id, :integer
  end
end
