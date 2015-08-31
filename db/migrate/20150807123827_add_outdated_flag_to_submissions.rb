class AddOutdatedFlagToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :outdated, :boolean, default: false, null: false
  end
end
