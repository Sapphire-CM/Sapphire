class ChangeEvalutations < ActiveRecord::Migration
  def change
    add_column :evalutions, :type, :string
    add_column :evalutions, :value, :integer
  end
end
