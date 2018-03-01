class RemoveMatriculationNumberUniquenessConstraintFromAccounts < ActiveRecord::Migration
  def change
    remove_index(:accounts, :matriculation_number)
  end
end