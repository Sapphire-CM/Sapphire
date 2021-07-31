class AddAutomatedCheckerIdentifierToRatings < ActiveRecord::Migration[4.2]
  def change
    add_column :ratings, :automated_checker_identifier, :string
  end
end
