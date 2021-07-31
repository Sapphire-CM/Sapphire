class AddMultiplicationFactorToRating < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :multiplication_factor, :float
  end
end
