class ChangeMatriculumNumberOnAccounts < ActiveRecord::Migration
  def change
    rename_column :accounts, :matriculum_number, :matriculation_number
  end
end
