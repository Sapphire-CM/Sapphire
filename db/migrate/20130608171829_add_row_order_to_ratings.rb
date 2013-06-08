class AddRowOrderToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :row_order, :integer, default: 0
  end
end
