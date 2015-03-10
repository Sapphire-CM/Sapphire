class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type
      t.references :subject, index: true, null: false, polymorphic: true
      t.references :account, index: true, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true

      t.text :data
      t.timestamps null: false
    end
  end
end
