class AddEnableRangePointsToRatingGroup < ActiveRecord::Migration
  def change
    add_column :rating_groups, :enable_range_points, :boolean
  end
end
