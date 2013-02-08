class AddTutorToTutorialGroup < ActiveRecord::Migration
  def change
    add_index :tutorial_group, :tutor_id
  end
end
