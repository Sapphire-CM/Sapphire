class AddPointsToTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :terms, :points, :integer
  end
end
