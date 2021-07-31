class AddRowOrderToRatingGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_groups, :row_order, :integer
  end
end
