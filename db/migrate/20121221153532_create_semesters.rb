class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.string :title
      t.boolean :active
      t.references :course

      t.timestamps
    end
    
    add_index :semesters, :course_id
  end
end