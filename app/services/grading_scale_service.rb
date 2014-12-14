class GradingScaleService
  class GradingRange
    attr_accessor :grading_scale, :grade, :range

    def initialize(grading_scale, grade, range, options)
      @grading_scale = grading_scale
      @grade = grade
      @range = range
      @is_positive = options[:positive]
      @not_graded = options[:not_graded].nil? ? false : options[:not_graded]
    end

    def include?(points)
      @range.include?(points)
    end

    def matches?(term_registration)
      if @not_graded && !term_registration.receives_grade?
        true
      else
        if term_registration.receives_grade?
          if @is_positive
            include?(term_registration.points) && term_registration.positive_grade?
          else
            include?(term_registration.points) || term_registration.negative_grade?
          end
        else
          false
        end
      end
    end

    def students
      @students ||= begin
        term_registrations = @grading_scale.term_registrations
        if @not_graded
          term_registrations.ungraded
        else
          if @is_positive
            term_registrations.graded.where {(points >> my{range}) & sift(:positive_grades) }
          else
            term_registrations.graded.where {(points >> my{range}) | sift(:negative_grades) }
          end
        end
      end
    end

    def student_count
      @student_count ||= students.count
    end

    def minimum_points
      @range.begin
    end

    def maximum_points
      @range.end
    end
  end

  attr_reader :term, :term_registrations

  def initialize(term, term_registrations = nil)
    @term = term

    if term_registrations.present?
      @term_registrations = term_registrations
    else
      @term_registrations = term.term_registrations.students
    end
    setup_grading_ranges!
  end

  def grades
    @grading_ranges.map(&:grade)
  end

  def grading_ranges
    @grading_ranges
  end

  def students_for(grade)
    grading_range_for(grade).students
  end

  def count_for(grade)
    grading_range_for(grade).student_count
  end

  def percent_for(grade)
    if total_count > 0
      (count_for(grade).to_f / graded_count) * 100
    else
      0
    end
  end

  def grade_for_student(student)
    grade_for_term_registration(student.term_registrations.find_by_term(@term))
  end

  def grade_for_term_registration(term_registration)
    term_registration.exercise_registrations.load
    if term_registration.any_exercise_submitted?
      @grading_ranges.find {|grading_range|  grading_range.matches? term_registration }.grade
    else
      0
    end
  end

  def range_for(grade)
    grading_range_for(grade).range
  end

  def total_count
    @grading_ranges.map(&:student_count).sum
  end

  def graded_count
    @term_registrations.graded.count
  end

  def ungraded_students_count
    @term_registrations.ungraded.count
  end

  def min_points_for(grade)
    grading_range_for(grade).minimum_points
  end

  def max_points_for(grade)
    grading_range_for(grade).maximum_points
  end

  private
  def grading_range_for(grade)
    @grading_ranges.find {|scale| scale.grade == grade} || GradingRange.new(self, 0, nil, {positive: false, not_graded: true})
  end

  def setup_grading_ranges!
    @grading_ranges = []

    grading_scale = @term.grading_scale.dup.map(&:first)

    grading_scale << @term.points + 1
    grading_scale.sort!
    grading_scale.reverse!

    (grading_scale.size - 1).times do |i|
      positive_grade = i != grading_scale.size - 2

      @grading_ranges << GradingRange.new(self, i + 1, Range.new(grading_scale[i + 1], grading_scale[i] - 1), {positive: positive_grade, not_graded: false})
    end
  end
end
