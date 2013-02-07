class CreateRatingGroups < ActiveRecord::Migration
  def change
    create_table :rating_groups do |t|
      t.references :exercise
      t.string :title
      t.integer :points

      t.timestamps
    end
    add_index :rating_groups, :exercise_id
  end
end
