class AddTopicIdentifierToStudentGroup < ActiveRecord::Migration
  def change
    add_column :student_groups, :topic_identifier, :string
  end
end
