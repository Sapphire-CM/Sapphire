class RemoveStudentGroupRegistrationFromSubmissions < ActiveRecord::Migration
  def change
    remove_reference :submissions, :student_group_registration, index: true
    remove_foreign_key :submissions, :student_group_registrations
  end
end
