class ChangeTermRegistrationRoleType < ActiveRecord::Migration[4.2]
  def up
    add_column :term_registrations, :new_role, :integer, default: 0

    [
      "UPDATE term_registrations SET new_role = '#{TermRegistration.roles[:student]}'  WHERE role = 'student'",
      "UPDATE term_registrations SET new_role = '#{TermRegistration.roles[:tutor]}'    WHERE role = 'tutor'",
      "UPDATE term_registrations SET new_role = '#{TermRegistration.roles[:lecturer]}' WHERE role = 'lecturer'",
    ].each do |query|
      TermRegistration.connection.execute query
    end

    remove_column :term_registrations, :role
    rename_column :term_registrations, :new_role, :role
  end

  def down
    change_column :term_registrations, :role, :string
  end
end
