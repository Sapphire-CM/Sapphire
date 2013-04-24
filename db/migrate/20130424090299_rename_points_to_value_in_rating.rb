class RenamePointsToValueInRating < ActiveRecord::Migration
  def change
    rename_column :ratings, :points, :value
  end
end
