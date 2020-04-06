class AddDirtyBitToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :dirty_bit, :boolean, default: false
  end
end
