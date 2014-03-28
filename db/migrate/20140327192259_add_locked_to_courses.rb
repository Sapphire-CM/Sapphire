class AddLockedToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :locked, :boolean, default: true
  end
end
