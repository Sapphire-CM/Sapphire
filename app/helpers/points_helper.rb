module PointsHelper
  def points(points)
    points ||= 0

    pluralized_string = if points.abs == 1
      "point"
    else
      "points"
    end

    "#{points} #{pluralized_string}"
  end
end
