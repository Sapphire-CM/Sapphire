module RatingsHelper
  def link_to_rating(title, rating, options = {})
    link_to title, course_term_exercise_rating_group_rating_path(current_course, current_term, rating.exercise, rating.rating_group, rating), options
  end
end
