class AddAutomatedCheckerIdentifierToRatings < ActiveRecord::Migration
  def change
    add_column :ratings, :automated_checker_identifier, :string
  end
end
