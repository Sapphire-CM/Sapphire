class AddRowOrderToRatings < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :row_order, :integer
  end
end
