class RenamePointsToValueInRating < ActiveRecord::Migration[4.2]
  def change
    rename_column :ratings, :points, :value
  end
end
