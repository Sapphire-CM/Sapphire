class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :commentable, index: true, null: false, polymorphic: true
      t.references :account, index: true, null: false, foreign_key: true
      t.references :term, null: false, foreign_key: true

      t.text :content
      t.boolean :internal, default: false

      t.timestamps null: false
    end
  end
end
