class CreateTermRegistrations < ActiveRecord::Migration[4.2]
  def change
    create_table :term_registrations do |t|
      t.string :role
      t.integer :points, index: true
      t.boolean :positive_grade, index: true, null: false, default: false
      t.belongs_to :account, index: true
      t.belongs_to :term, index: true
      t.belongs_to :tutorial_group, index: true

      t.timestamps null: false
    end
  end
end
