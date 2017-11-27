class TermBasedPolicy < ApplicationPolicy
  def self.term_policy_record(term)
    raise ArgumentError.new("#{term} is not a Term") unless term.is_a? Term

    policy_record_with(term: term)
  end

  protected

  def staff_permissions?(term = record.term)
    admin? || staff?(term)
  end

  def lecturer_permissions?(term = record.term)
    admin? || lecturer?(term)
  end


  def staff?(term = record.term)
    user.staff_of_term?(term)
  end

  def lecturer?(term = record.term)
    user.lecturer_of_term?(term)
  end

  def tutor?(term = record.term)
    user.tutor_of_term?(term)
  end

  def student?(term = record.term)
    user.student_of_term?(term)
  end

end