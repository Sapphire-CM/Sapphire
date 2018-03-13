class RenameOutdatedToActiveOfSubmissions < ActiveRecord::Migration
  class Submission < ActiveRecord::Base; end
  def change
    add_column :submissions, :active, :boolean, default: true, null: false

    say_with_time "Migrating data" do
      reversible do |dir|
        dir.up do
          Submission.where(outdated: true).update_all(active: false)
          Submission.where(outdated: false).update_all(active: true)
        end

        dir.down do
          Submission.where(active: true).update_all(outdated: false)
          Submission.where(active: false).update_all(outdated: true)
        end
      end
    end

    remove_column :submissions, :outdated, :boolean
  end
end