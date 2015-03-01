class RemoveTutorRegistrations < ActiveRecord::Migration
  def up
    drop_table :tutor_registrations
  end

  def down
    create_table :tutor_registrations do |t|
      t.belongs_to  :account
      t.belongs_to  :tutorial_group

      t.timestamps
    end
  end
end
