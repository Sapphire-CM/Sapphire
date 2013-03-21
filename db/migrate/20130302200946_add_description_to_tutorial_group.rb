class AddDescriptionToTutorialGroup < ActiveRecord::Migration
  def change
    add_column :tutorial_groups, :description, :text
  end
end
