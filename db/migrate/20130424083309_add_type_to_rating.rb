class AddTypeToRating < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :type, :string
  end
end
