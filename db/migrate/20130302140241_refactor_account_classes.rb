class RefactorAccountClasses < ActiveRecord::Migration
  def up
    drop_table :tutors
    drop_table :students
    drop_table :term_registrations

    add_column    :accounts, :forename, :string
    add_column    :accounts, :surname, :string
    add_column    :accounts, :matriculum_number, :string
    
    remove_column :courses, :course_leader_id
    
    remove_column :terms, :active
    add_column    :terms, :description, :string

    remove_column :tutorial_groups, :tutor_id

    create_table :lecturer_term_registrations do |t|
      t.integer  :account_id
      t.integer  :term_id
      t.datetime :registered_at
      t.timestamps
    end
    add_index :lecturer_term_registrations, ["account_id"], :name => "index_lecturer_term_registrations_on_account_id"
    add_index :lecturer_term_registrations, ["term_id"], :name => "index_lecturer_term_registrations_on_term_id"

    create_table :tutor_term_registrations do |t|
      t.integer  :account_id
      t.integer  :tutorial_group_id
      t.datetime :registered_at
      t.timestamps
    end
    add_index :tutor_term_registrations, ["account_id"], :name => "index_tutor_term_registrations_on_account_id"
    add_index :tutor_term_registrations, ["tutorial_group_id"], :name => "index_tutor_term_registrations_on_tutorial_group_id"

    create_table :student_term_registrations do |t|
      t.integer  :account_id
      t.integer  :tutorial_group_id
      t.datetime :registered_at
      t.timestamps
    end
    add_index :student_term_registrations, ["account_id"], :name => "index_student_term_registrations_on_account_id"
    add_index :student_term_registrations, ["tutorial_group_id"], :name => "index_student_term_registrations_on_tutorial_group_id"

  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
