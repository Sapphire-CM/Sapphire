class AddOptionsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :options, :text
  end
end
