class AddDescriptionToRatingGroup < ActiveRecord::Migration
  def change
    add_column :rating_groups, :description, :text
  end
end
