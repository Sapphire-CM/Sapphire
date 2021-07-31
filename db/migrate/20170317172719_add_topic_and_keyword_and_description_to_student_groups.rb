class AddTopicAndKeywordAndDescriptionToStudentGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :student_groups, :keyword, :string
    add_column :student_groups, :topic, :string
    add_column :student_groups, :description, :text
  end
end
