module RatingGroupsHelper

  def subtitle_points(rating_group)
    subtitle = "#{pluralize rating_group.points, "point"}"
    subtitle += " (#{rating_group.min_points} ... #{rating_group.max_points})" if rating_group.enable_range_points
  end

end
