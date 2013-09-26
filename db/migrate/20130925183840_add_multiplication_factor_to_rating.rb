class AddMultiplicationFactorToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :multiplication_factor, :float
  end
end
