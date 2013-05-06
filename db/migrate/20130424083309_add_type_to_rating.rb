class AddTypeToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :type, :string
  end
end
