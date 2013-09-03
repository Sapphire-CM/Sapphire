class AddStudentGroupRegistrationAndRemoveStudentRegistrationIdFromSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :student_group_registration_id, :integer
    add_index :submissions, :student_group_registration_id

    remove_index :submissions, :student_registration_id
    remove_column :submissions, :student_registration_id, :integer

  end
end
