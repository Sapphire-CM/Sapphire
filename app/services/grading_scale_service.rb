class GradingScaleService
  class GradingRange
    attr_accessor :grade, :range, :is_positive, :not_graded

    def initialize(grading_scale, grade, range, options)
      @grading_scale = grading_scale
      @grade = grade
      @range = range
      @is_positive = options[:is_positive]
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
        if term_registrations.present?
          if @not_graded
            term_registrations.ungraded
          else
            if @is_positive
              term_registrations.graded.where {(points >> my{range}) & sift(:positive_grades) }
            else
              term_registrations.graded.where {(points >> my{range}) | sift(:negative_grades) }
            end
          end
        else
          []
        end
      end
    end

    def student_count
      @student_count ||= students.length
    end

    def minimum_points
      @range.begin
    end

    def maximum_points
      @range.end
    end

    def maximum_ui_points
      [@grading_scale.maximum_ui_points, maximum_points].min
    end
  end

  attr_reader :term, :term_registrations, :grading_ranges

  def initialize(term, term_registrations)
    @term = term
    @term_registrations = term_registrations if term_registrations.present?

    setup_grading_ranges!
  end

  def to_a
    @grading_ranges.map { |r| [r.minimum_points, r.grade.to_s] }
  end

  def update_range(grade, points)
    grading_range = grading_range_for(grade.to_i)
    @grading_ranges.delete grading_range

    new_range = [points.to_i, grading_range.maximum_points].sort
    @grading_ranges << GradingRange.new(self, grade, Range.new(new_range.first, new_range.last), is_positive: grading_range.is_positive, not_graded: grading_range.not_graded)
  end

  def maximum_ui_points
    @maximum_ui_points ||= @term.achievable_points
  end

  def grades
    @grading_ranges.map(&:grade)
  end

  def students_for(grade)
    grading_range_for(grade).students
  end

  def count_for(grade)
    grading_range_for(grade).student_count
  end

  def percent_for(grade)
    if graded_count > 0
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
      @grading_ranges.find { |grading_range|  grading_range.matches? term_registration }.grade
    else
      0
    end
  end

  def average_grade_for_student_group(student_group)
    grades = student_group.term_registrations.map { |tr| grade_for_term_registration(tr) }

    stats = grades.inject(Hash.new {|h,k| h[k] = 0}) do |hash, grade|
      hash[grade] += 1
      hash
    end

    student_count = 0
    grade_sum = 0
    stats.each do |grade, count|
      if grade > 0
        grade_sum += grade * count
        student_count += count
      end
    end

    if student_count > 0
      grade_sum.to_f / student_count
    else
      0
    end
  end

  def range_for(grade)
    grading_range_for(grade).range
  end

  def total_count
    @grading_ranges.sum(&:student_count)
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

  def min_points_for(grade)
    grading_range_for(grade).minimum_points
  end

  def max_points_for(grade)
    grading_range_for(grade).maximum_points
  end

  def max_ui_points_for(grade)
    grading_range_for(grade).maximum_ui_points
  end

  private

  def grading_range_for(grade)
    @grading_ranges.find { |scale| scale.grade == grade } || GradingRange.new(self, 0, nil, is_positive: false, not_graded: true)
  end

  def setup_grading_ranges!
    @grading_ranges = []

    grading_scale = @term.read_attribute(:grading_scale).map(&:first) # the grade is derived by the order itself
    grading_scale = [0, 51, 64, 80, 90] if grading_scale.compact.empty?

    grading_scale << (@term.points || 0) + 1
    grading_scale.sort!
    grading_scale.reverse!

    (grading_scale.size - 1).times do |i|
      positive_grade = i != grading_scale.size - 2

      @grading_ranges << GradingRange.new(self, i + 1, Range.new(grading_scale[i + 1], grading_scale[i] - 1), is_positive: positive_grade, not_graded: false)
    end
  end
end
