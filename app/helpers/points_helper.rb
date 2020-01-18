module PointsHelper
  def points(points)
    points ||= 0

    pluralized_string = if points.abs == 1
      "point"
    else
      "points"
    end

    "#{"%g" % points} #{pluralized_string}"
  end

  def trim_points(points)
    "#{"%g" % points}"
  end
end
