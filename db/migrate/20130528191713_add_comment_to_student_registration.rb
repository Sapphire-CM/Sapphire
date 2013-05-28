class AddCommentToStudentRegistration < ActiveRecord::Migration
  def change
    add_column :student_registrations, :comment, :string
  end
end
