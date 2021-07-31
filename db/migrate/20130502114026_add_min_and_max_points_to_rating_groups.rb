class AddMinAndMaxPointsToRatingGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_groups, :min_points, :integer
    add_column :rating_groups, :max_points, :integer
  end
end
