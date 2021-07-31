class DeleteRegisteredAt < ActiveRecord::Migration[4.2]
  def change
    remove_column :lecturer_registrations, :registered_at, :datetime
    remove_column :tutor_registrations, :registered_at, :datetime
    remove_column :student_registrations, :registered_at, :datetime
  end
end
