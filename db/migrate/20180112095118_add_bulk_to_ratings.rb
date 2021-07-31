class AddBulkToRatings < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :bulk, :boolean, default: false
  end
end
