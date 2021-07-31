class RemoveDuplicatedColumn < ActiveRecord::Migration[4.2]
  def change
    remove_column :exercises, :allow_student_uploads, :boolean
  end
end
