class ChangeMatriculumNumberOnAccounts < ActiveRecord::Migration[4.2]
  def change
    rename_column :accounts, :matriculum_number, :matriculation_number
  end
end
