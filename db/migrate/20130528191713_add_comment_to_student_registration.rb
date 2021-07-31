class AddCommentToStudentRegistration < ActiveRecord::Migration[4.2]
  def change
    add_column :student_registrations, :comment, :string
  end
end
