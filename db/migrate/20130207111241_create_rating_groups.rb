class CreateRatingGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :rating_groups do |t|
      t.references :exercise
      t.string :title
      t.integer :points

      t.timestamps null: false
    end
    add_index :rating_groups, :exercise_id
  end
end
