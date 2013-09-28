module ExercisesHelper
  def exercise_sub_title(exercise)
    value = []
    value << "#{pluralize(exercise.points, 'point')}"
    value << "min: #{exercise.min_required_points}" if exercise.enable_min_required_points
    value << "max: #{exercise.max_total_points}" if exercise.enable_max_total_points

    value.join ', '
  end

end
