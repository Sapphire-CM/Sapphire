class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.references :tutorial_group
      t.references :submission_group
      t.string :forename
      t.string :surname
      t.integer :matriculum_number
      t.string :email
      t.datetime :registration_date

      t.timestamps null: false
    end
    add_index :students, :tutorial_group_id
    add_index :students, :submission_group_id
  end
end
