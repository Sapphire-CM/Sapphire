class AddAdminToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :admin, :boolean
  end
end
