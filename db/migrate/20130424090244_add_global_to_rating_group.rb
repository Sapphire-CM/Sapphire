class AddGlobalToRatingGroup < ActiveRecord::Migration
  def change
    add_column :rating_groups, :global, :boolean
  end
end
