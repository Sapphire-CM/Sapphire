class ChangeEvalutations < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluations, :type, :string
    add_column :evaluations, :value, :integer, after: :checked
  end
end
