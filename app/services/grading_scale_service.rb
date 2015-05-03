class GradingScaleService
  attr_accessor :term, :term_registrations

  def initialize(term, term_registrations = nil)
    @term = term
    @term_registrations = term_registrations || term.term_registrations.students
    @grading_scales = @term.grading_scales
  end

  def count_for(grading_scale)
    return 0 unless @term_registrations

    if grading_scale.not_graded
      @term_registrations.ungraded.length
    else
      range = (grading_scale.min_points..grading_scale.max_points)
      tr = if grading_scale.positive
        @term_registrations.graded.where { (points >> my { range }) & sift(:positive_grades) }
      else
        @term_registrations.graded.where { (points >> my { range }) | sift(:negative_grades) }
      end
      tr.length
    end
  end

  def percent_for(grading_scale)
    if graded_count > 0
      (count_for(grading_scale).to_f / graded_count.to_f) * 100.0
    else
      0.0
    end
  end

  def grade_for(term_registration)
    gs = if term_registration.receives_grade?
      if term_registration.positive_grade?
        if term_registration.points > @grading_scales.positives.first.max_points
          @grading_scales.positives.first
        elsif term_registration.points < @grading_scales.negative.min_points
          @grading_scales.negative
        else
          @grading_scales.where {
            (min_points <= my { term_registration.points }) &
            (max_points >= my { term_registration.points }) &
            (not_graded == false)
          }.ordered.first
        end
      else
        @grading_scales.negative
      end
    else
      @grading_scales.not_graded
    end
    gs.grade
  end

  def graded_count
    if @term_registrations.present?
      @term_registrations.graded.count
    else
      0
    end
  end

  def ungraded_count
    if @term_registrations.present?
      @term_registrations.ungraded.count
    else
      0
    end
  end
end
