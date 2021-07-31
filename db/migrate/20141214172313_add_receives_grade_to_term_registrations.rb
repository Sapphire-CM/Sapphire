class AddReceivesGradeToTermRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :term_registrations, :receives_grade, :boolean

    TermRegistration.all.each(&:update_points!)
  end
end
