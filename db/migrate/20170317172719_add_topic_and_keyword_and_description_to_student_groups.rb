class AddTopicAndKeywordAndDescriptionToStudentGroups < ActiveRecord::Migration
  def change
    add_column :student_groups, :keyword, :string
    add_column :student_groups, :topic, :string
    add_column :student_groups, :description, :text
  end
end
