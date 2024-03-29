class RemoveTutorRegistrations < ActiveRecord::Migration[4.2]
  def up
    drop_table :tutor_registrations
  end

  def down
    create_table :tutor_registrations do |t|
      t.belongs_to  :account
      t.belongs_to  :tutorial_group

      t.timestamps null: false
    end
  end
end
