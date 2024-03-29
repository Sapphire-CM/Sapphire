class CreateServices < ActiveRecord::Migration[4.2]
  def change
    create_table :services do |t|
      t.belongs_to :exercise
      t.boolean :active, default: false
      t.string :type
      t.text :properties

      t.timestamps null: false
    end
  end
end
