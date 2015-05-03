class GradingScaleService
  attr_accessor :term, :term_registrations

  def initialize(term, term_registrations = false)
    @term = term
    @term_registrations = term_registrations if term_registrations.present?
    @grading_scales = @term.grading_scales
  end

  def count_for(grading_scale)
    return 0 unless @term_registrations

    if grading_scale.not_graded
      @term_registrations.ungraded
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

  def percent_for(grade)
    if graded_count > 0
      (count_for(grade).to_f / graded_count.to_f) * 100.0
    else
      0.0
    end
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
