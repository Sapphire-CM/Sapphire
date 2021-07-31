class RemoveMatriculationNumberUniquenessConstraintFromAccounts < ActiveRecord::Migration[4.2]
  def change
    remove_index(:accounts, :matriculation_number)
  end
end