class AddOutdatedAndReplacementFlagsToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :outdated, :boolean, default: false
    add_column :submissions, :replacement, :boolean, default: false
  end
end
