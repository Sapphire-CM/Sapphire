class RemoveLecturerRegistrations < ActiveRecord::Migration[4.2]
  def up
    drop_table :lecturer_registrations
  end

  def down
    create_table :lecturer_registrations do |t|
      t.belongs_to  :account
      t.belongs_to  :term

      t.timestamps null: false
    end
  end
end
