class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.references :commentable, index: true, null: false, polymorphic: true
      t.references :account, index: true, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :markdown, null: false, default: false

      t.text :content, null: false

      t.timestamps null: false
    end
  end
end
