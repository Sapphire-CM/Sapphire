class CreateCourses < ActiveRecord::Migration[4.2]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.references :course_leader

      t.timestamps null: false
    end

    add_index :courses, :course_leader_id
  end
end
