class SubmissionBulks::SubjectsFinder
  include ActiveModel::Model

  attr_accessor :exercise

  def search(query)
    if exercise.solitary_submission?
      search_term_registrations(query)
    else
      search_student_groups(query)
    end
  end

  def find(ids)
    if exercise.solitary_submission?
      find_term_registrations(ids)
    else
      find_student_groups(ids)
    end
  end

  private
  def term
    exercise.term
  end

  def student_groups
    term.student_groups
  end

  def term_registrations
    term.term_registrations.students
  end

  def search_student_groups(query)
    student_groups.where("student_groups.title LIKE ?", "%#{query}%")
  end

  def search_term_registrations(query)
    term_registrations.search(query).includes(:account, :tutorial_group)
  end

  def find_student_groups(ids)
    student_groups.find(ids)
  end

  def find_term_registrations(ids)
    term_registrations.includes(:account, :tutorial_group).find(ids)
  end
end