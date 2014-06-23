module PointsOverviewHelper
  def exercise_result(term_registration, exercise)
    term_registration.exercise_registrations.find {|ex_reg| ex_reg.exercise_id == exercise.id}.try(:points).presence || "na"
  end


  def points_overview_for_tutorial_group(tutorial_group, grading_scale = nil)
    term_registrations = tutorial_group.term_registrations.students
    grading_scale = GradingScaleService.new(@term, term_registrations) if grading_scale.nil?
    term_registrations = term_registrations.includes(:account, :exercise_registrations).ordered_by_matriculation_number

    render 'points_overview/tutorial_group', term: tutorial_group.term, tutorial_group: tutorial_group, term_registrations: term_registrations, grading_scale: grading_scale
  end
end
