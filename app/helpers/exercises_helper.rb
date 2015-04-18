module ExercisesHelper
  def exercise_topbar_link(exercise)
    link_to exercise.title, rolebased_submission_path(exercise)
  end

  def exercise_sub_title(exercise)
    value = []
    value << "#{pluralize(exercise.points, 'point')}"
    value << "min: #{exercise.min_required_points}" if exercise.enable_min_required_points
    value << "max: #{exercise.max_total_points}" if exercise.enable_max_total_points

    value.join ', '
  end

  def submission_viewer_form_collection
    Sapphire::SubmissionViewers::Central.registered_viewers.map do |viewer|
      [viewer.title, viewer.identifier]
    end
  end

  def conditional_submissions_link(exercise)
    if exercise.term.tutorial_groups.any?
      link_to exercise.title, rolebased_submission_path(exercise)
    else
      exercise.title
    end
  end

  def rolebased_submission_path(exercise)
    if policy(exercise.term).student?
      exercise_student_submission_path(exercise)
    else
      exercise_submissions_path(exercise)
    end
  end

  def exercise_sidebar_administrate_active?
    params[:controller] == 'result_publications' ||
    params[:controller] == 'rating_groups' ||
    params[:controller] == 'services' ||
    (params[:controller] == 'exercises' && params[:action] == 'edit')
  end
end
