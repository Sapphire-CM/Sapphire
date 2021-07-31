class AddEnableRangePointsToRatingGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_groups, :enable_range_points, :boolean
  end
end
