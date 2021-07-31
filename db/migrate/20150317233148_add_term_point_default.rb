class AddTermPointDefault < ActiveRecord::Migration[4.2]
  def change
    change_column :terms, :points, :integer, default: 0
  end
end
