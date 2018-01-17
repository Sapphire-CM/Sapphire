class AddBulkToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :bulk, :boolean, default: false
  end
end
