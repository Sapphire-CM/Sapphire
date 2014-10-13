class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.string :type
      t.integer :status
      t.belongs_to :term, index: true
      t.string :file
      t.text :properties
      t.timestamps
    end
  end
end
