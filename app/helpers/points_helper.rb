module PointsHelper
  def points(points)
    pluralized_string = if points.abs == 1
      "point"
    else
      "points"
    end

    "#{points} #{pluralized_string}"
  end
end
