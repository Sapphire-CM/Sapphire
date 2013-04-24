class AddMaxMinValuesToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :max_value, :integer
    add_column :ratings, :min_value, :integer
  end
end
