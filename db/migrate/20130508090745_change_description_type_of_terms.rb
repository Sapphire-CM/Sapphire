class ChangeDescriptionTypeOfTerms < ActiveRecord::Migration[4.2]
  def change
    remove_column :terms, :description
    add_column :terms, :description, :text
  end
end
