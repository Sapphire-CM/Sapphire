class SubmissionBulks::SubmissionsFinder
  include ActiveModel::Model

  attr_accessor :exercise

  def find_submissions_for_subjects(subjects)
    if exercise.solitary_submission?
      find_submissions_for_term_registrations(subjects)
    else
      find_submissions_for_student_groups(subjects)
    end
  end

  private

  def find_submissions_for_term_registrations(term_registrations)
    @exercise.submissions.current.for_term_registration(term_registrations).index_by { |submission| submission.term_registrations.first }
  end

  def find_submissions_for_student_groups(student_groups)
    @exercise.submissions.current.for_student_group(student_groups).index_by(&:student_group)
  end
end