class GradingOverview
  attr_reader :term, :grading_scales, :tutorial_groups, :overall_grading_scale_service

  def initialize(term, grading_scales, tutorial_groups)
    @term = term
    @grading_scales = grading_scales
    @tutorial_groups = tutorial_groups

    @overall_grading_scale_service = GradingScaleService.new(term)
    @grading_scale_services = Hash.new { |h,k| h[k] = GradingScaleService.new(k.term, k.student_term_registrations) }
  end

  def count_for_tutorial_group_and_grading_scale(tutorial_group, grading_scale)
    @grading_scale_services[tutorial_group].count_for(grading_scale)
  end

  def student_count_for_tutorial_group(tutorial_group)
    @grading_scale_services[tutorial_group].term_registrations.count
  end

  def count_for_grading_scale(grading_scale)
    overall_grading_scale_service.count_for(grading_scale)
  end

  def percent_for_grading_scale(grading_scale)
    overall_grading_scale_service.percent_for(grading_scale)
  end

  def graded_count
    overall_grading_scale_service.graded_count
  end

  def ungraded_count
    overall_grading_scale_service.ungraded_count
  end

  def graded_count_for_tutorial_group(tutorial_group)
    @grading_scale_services[tutorial_group].term_registrations.graded.count
  end

  def ungraded_count_for_tutorial_group(tutorial_group)
    @grading_scale_services[tutorial_group].term_registrations.ungraded.count
  end

  def students_count
    graded_count + ungraded_count
  end

end
