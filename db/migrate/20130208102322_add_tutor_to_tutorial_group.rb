class AddTutorToTutorialGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :tutorial_groups, :tutor_id, :integer
  end
end
