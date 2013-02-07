class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :rating_group
      t.string :title
      t.integer :points

      t.timestamps
    end
    add_index :ratings, :rating_group_id
  end
end
