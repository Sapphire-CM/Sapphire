class AddPolymorphicAssociationsToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :accountable_type, :string
    add_column :accounts, :accountable_id, :integer
    add_index :accounts, [:accountable_id, :accountable_type], :unique => true 
  end
end