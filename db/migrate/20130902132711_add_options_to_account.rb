class AddOptionsToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :options, :text
  end
end
