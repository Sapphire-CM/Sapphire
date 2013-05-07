class ChangeDescriptionTypeOfTerms < ActiveRecord::Migration
  def change
    remove_column :terms, :description
    add_column :terms, :description, :text
  end
end
