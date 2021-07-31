class AddWelcomedAtToTermRegistrations < ActiveRecord::Migration[4.2]
  class TermRegistration < ActiveRecord::Base; end

  def change
    add_column :term_registrations, :welcomed_at, :datetime

    reversible do |dir|
      dir.up do
        execute "UPDATE term_registrations SET welcomed_at=created_at;"
      end
    end
  end
end
