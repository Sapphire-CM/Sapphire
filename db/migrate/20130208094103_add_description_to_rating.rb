class AddDescriptionToRating < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :description, :text
  end
end
