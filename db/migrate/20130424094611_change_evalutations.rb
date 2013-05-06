class ChangeEvalutations < ActiveRecord::Migration
  def change
    add_column :evaluations, :type, :string
    add_column :evaluations, :value, :integer, after: :checked
  end
end
