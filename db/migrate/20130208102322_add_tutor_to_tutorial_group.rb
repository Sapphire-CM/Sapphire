class AddTutorToTutorialGroup < ActiveRecord::Migration
  def change
    add_column :tutorial_groups, :tutor_id, :integer
  end
end
