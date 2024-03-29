class CreateEvaluations < ActiveRecord::Migration[4.2]
  def change
    create_table :evaluations do |t|
      t.boolean :checked
      t.references :student
      t.references :rating

      t.timestamps null: false
    end
    add_index :evaluations, :student_id
    add_index :evaluations, :rating_id
  end
end
