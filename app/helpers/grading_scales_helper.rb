module GradingScalesHelper
  def grading_scale_max_points_with_ui_points(grading_scale, grade)
    max_ui_points = grading_scale.max_ui_points_for(grade)
    max_points = grading_scale.max_points_for(grade)

    if max_ui_points != max_points
      "#{max_ui_points} (#{max_points})"
    else
      max_points
    end
  end
end
