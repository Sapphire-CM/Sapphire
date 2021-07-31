class AddLockedToCourses < ActiveRecord::Migration[4.2]
  def change
    add_column :courses, :locked, :boolean, default: true
  end
end
