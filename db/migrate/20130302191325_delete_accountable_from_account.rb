class DeleteAccountableFromAccount < ActiveRecord::Migration
  def up
    remove_index :accounts, :column => [ :accountable_id, :accountable_type ]
    remove_column :accounts, :accountable_type
    remove_column :accounts, :accountable_id
  end

  def down
    add_column :accounts, :accountable_type, :string
    add_column :accounts, :accountable_id, :integer
  end
end
