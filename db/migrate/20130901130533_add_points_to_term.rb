class AddPointsToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :points, :integer
  end
end
