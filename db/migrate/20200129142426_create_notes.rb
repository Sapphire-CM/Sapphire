class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.references :notable, index: true, null: false, polymorphic: true
      t.references :account, index: true, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true

      t.text :content

      t.timestamps null: false
    end
  end
end
