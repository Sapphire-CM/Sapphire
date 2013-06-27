class AddRowOrderPostionToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :row_order, :integer
  end
end
