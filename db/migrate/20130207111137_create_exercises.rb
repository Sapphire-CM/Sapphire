class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.references :term
      t.string :title

      t.timestamps
    end
    add_index :exercises, :term_id
  end
end
