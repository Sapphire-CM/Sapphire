class AddTermPointDefault < ActiveRecord::Migration
  def change
    change_column :terms, :points, :integer, default: 0
  end
end
