class CreateTermRegistrationsOld < ActiveRecord::Migration
  def change
    create_table :term_registrations do |t|
      t.datetime :registered_at
      t.references :tutorial_group
      t.references :term
      t.references :student

      t.timestamps
    end
    add_index :term_registrations, :tutorial_group_id
    add_index :term_registrations, :term_id
    add_index :term_registrations, :student_id
  end
end
