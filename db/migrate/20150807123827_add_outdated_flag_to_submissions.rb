class AddOutdatedFlagToSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :submissions, :outdated, :boolean, default: false, null: false
  end
end
