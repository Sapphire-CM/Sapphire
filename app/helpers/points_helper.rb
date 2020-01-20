module PointsHelper
  def points(points)
    points ||= 0

    pluralized_string = if points.abs == 1
      "point"
    else
      "points"
    end

    "#{number_to_points(points)} #{pluralized_string}"
  end

  def number_to_points(points)
    number_with_precision(points, strip_insignificant_zeros: true)
  end
end
