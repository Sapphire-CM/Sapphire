class AddRowOrderPostionToTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :terms, :row_order, :integer
  end
end
