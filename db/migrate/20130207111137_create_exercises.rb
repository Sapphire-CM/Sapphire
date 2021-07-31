class CreateExercises < ActiveRecord::Migration[4.2]
  def change
    create_table :exercises do |t|
      t.references :term
      t.string :title

      t.timestamps null: false
    end
    add_index :exercises, :term_id
  end
end
