class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.boolean :checked
      t.references :student
      t.references :rating

      t.timestamps
    end
    add_index :evaluations, :student_id
    add_index :evaluations, :rating_id
  end
end
