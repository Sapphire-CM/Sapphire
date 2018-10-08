class GradingScaleService
  attr_accessor :term, :term_registrations
  attr_reader :grading_scales

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

  def average_grade_for_student_group(student_group)
    average_grade_for_term_registrations(student_group.term_registrations)
  end

  def average_grade_for_term_registrations(term_registrations)
    grades = term_registrations.map { |tr| grade_for(tr) }

    stats = grades.inject(Hash.new {|h,k| h[k] = 0}) do |hash, grade|
      hash[grade] += 1
      hash
    end

    student_count = 0
    grade_sum = 0

    stats.each do |grade, count|
      if grade.to_i > 0
        grade_sum += grade.to_i * count
        student_count += count
      end
    end

    if student_count > 0
      (grade_sum.to_f / student_count)
    else
      0
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
    @term_registrations.graded.count
  end

  def ungraded_count
    @term_registrations.ungraded.count
  end

  def distribution
    distribution = Hash.new { |h,k| h[k] = {positive: 0, negative: 0, points: k} }

    @term_registrations.dup.group(:points, :positive_grade).count.each do |group, count|
      points, positive = *group

      group_key = positive ? :positive : :negative

      distribution[points][group_key] = count
    end

    distribution.values
  end
end
