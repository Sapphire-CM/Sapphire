class RemoveStudentGroupRegistrationFromSubmissions < ActiveRecord::Migration[4.2]
  def change
    remove_reference :submissions, :student_group_registration, index: true
  end
end
