class AddGlobalToRatingGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :rating_groups, :global, :boolean
  end
end
