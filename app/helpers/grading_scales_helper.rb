module GradingScalesHelper
  def grading_scales_editor_tag(grading_scale_service)
    data = {
      behavior: "grading-scale-editor",
      distribution: grading_scale_service.distribution,
      scales: grading_scale_service.grading_scales.grades.to_json(only: [:id, :grade, :positive, :min_points, :max_points]),
      max_points: grading_scale_service.term.achievable_points,
      update_url: term_grading_scales_path(grading_scale_service.term)
    }

    content_tag :div, "", data: data, class: "grading-scales-editor"
  end
end
