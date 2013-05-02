class AddMinAndMaxPointsToRatingGroups < ActiveRecord::Migration
  def change
    add_column :rating_groups, :min_points, :integer
    add_column :rating_groups, :max_points, :integer
  end
end
