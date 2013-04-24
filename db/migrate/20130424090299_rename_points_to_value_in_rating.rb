class RenamePointsToValueInRating < ActiveRecord::Migration
  def change
    rename_column :rating, :points, :value
  end
end
