class CreateTutorialGroups < ActiveRecord::Migration
  def change
    create_table :tutorial_groups do |t|
      t.string :title
      t.references :term

      t.timestamps
    end
    add_index :tutorial_groups, :term_id
  end
end
