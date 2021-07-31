class AddDescriptionToRatingGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_groups, :description, :text
  end
end
