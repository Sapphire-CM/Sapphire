class CreateRatings < ActiveRecord::Migration[4.2]
  def change
    create_table :ratings do |t|
      t.references :rating_group
      t.string :title
      t.integer :points

      t.timestamps null: false
    end
    add_index :ratings, :rating_group_id
  end
end
