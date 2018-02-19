class TermRegistrationsPointsUpdateJob < ActiveJob::Base
  queue_as :default

  def perform(term_id)
    ActiveRecord::Base.transaction do
      term = Term.find(term_id)

      term_registrations = term.term_registrations.students.includes(exercise_registrations: [:exercise, submission: :submission_evaluation])
      term_registrations.find_each(&:update_points!)
    end
  end
end
