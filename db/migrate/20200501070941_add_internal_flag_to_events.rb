class AddInternalFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :internal, :boolean, default: false
  end
end
