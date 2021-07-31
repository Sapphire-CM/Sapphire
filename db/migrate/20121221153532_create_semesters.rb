class CreateSemesters < ActiveRecord::Migration[4.2]
  def change
    create_table :semesters do |t|
      t.string :title
      t.boolean :active
      t.references :course

      t.timestamps null: false
    end

    add_index :semesters, :course_id
  end
end
