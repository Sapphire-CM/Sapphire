class AddTopicIdentifierToStudentGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :student_groups, :topic_identifier, :string
  end
end
