class AddRowOrderToRatingGroups < ActiveRecord::Migration
  def change
    add_column :rating_groups, :row_order, :integer
  end
end
