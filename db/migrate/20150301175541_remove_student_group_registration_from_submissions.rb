class RemoveStudentGroupRegistrationFromSubmissions < ActiveRecord::Migration
  def change
    remove_reference :submissions, :student_group_registration, index: true
  end
end
