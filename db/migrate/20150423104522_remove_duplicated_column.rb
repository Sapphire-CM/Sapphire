class RemoveDuplicatedColumn < ActiveRecord::Migration
  def change
    remove_column :exercises, :allow_student_uploads, :boolean
  end
end
