module TermRegistrationsHelper
  def term_registrations_tutorial_group_options(term)
    term.tutorial_groups.order(:title).map do |tutorial_group|
      [tutorial_group_title(tutorial_group), tutorial_group.id]
    end
  end

  def term_registrations_student_group_options(term)
    term.student_groups.order(:title)
  end
end
