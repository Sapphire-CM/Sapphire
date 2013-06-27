class AddRowOrderToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :row_order, :integer
  end
end
