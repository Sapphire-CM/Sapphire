class AddLockableToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :failed_attempts, :integer, default: 0
    add_column :accounts, :unlock_token, :string
    add_column :accounts, :locked_at, :datetime
  end
end
