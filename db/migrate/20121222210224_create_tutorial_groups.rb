class CreateTutorialGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :tutorial_groups do |t|
      t.string :title
      t.references :term

      t.timestamps null: false
    end
    add_index :tutorial_groups, :term_id
  end
end
