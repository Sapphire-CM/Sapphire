module AccountsHelper
  def term_registration_title_for_accounts(term_registration)
    if term_registration.student? || term_registration.tutor?
      "#{course_term_title(term_registration.term)} (as #{term_registration.role} in #{tutorial_group_title term_registration.tutorial_group})"
    elsif term_registration.lecturer?
      "#{course_term_title(term_registration.term)} (as lecturer)"
    end
  end

  def account_detail_term_registration_path(term_registration)
    if term_registration.student?
      term_student_path(term_registration.term, term_registration)
    elsif term_registration.tutor?
      term_tutorial_group_path(term_registration.term, term_registration.tutorial_group)
    elsif term_registration.lecturer?
      term_path(term_registration.term)
    end
  end
end
