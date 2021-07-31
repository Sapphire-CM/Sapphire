class AddDescriptionToTutorialGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :tutorial_groups, :description, :text
  end
end
