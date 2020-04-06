class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.belongs_to :exercise
      t.integer :sum
      t.integer :min
      t.integer :max
      t.integer :average
      t.integer :median

      t.timestamps null: false
    end
    add_index :statistics, :exercise_id
  end
end
