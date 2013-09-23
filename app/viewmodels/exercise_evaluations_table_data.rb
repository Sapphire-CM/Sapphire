class ExerciseEvaluationsTableData

  attr_accessor :transpose, :exercise, :tutorial_group, :student_groups
  attr_reader :rating_groups

  def initialize(exercise, tutorial_group = nil, transpose = false, student_groups = nil)
    @exercise = exercise
    @tutorial_group = tutorial_group
    @transpose = transpose
    @student_groups = student_groups

    prepare_data!
  end

  def evaluation_for_student_group_and_rating(student_group, rating)
    @evaluations_by_student_groups_and_ratings[student_group][rating]
  end

  def evaluation_group_for_student_group_and_rating_group(student_group, rating_group)
    @evaluation_groups_by_student_groups_and_rating_groups[student_group][rating_group]
  end

  def submission_for_student_group(student_group)
    @submissions_by_student_groups[student_group]
  end

  def tutorial_group=(tutorial_group)
    if @tutorial_group != tutorial_group
      @tutorial_group = tutorial_group
      prepare_data!
    end
  end

  def exercise=(exercise)
    if @exercise != exercise
      @exercise = exercise
      prepare_data!
    end
  end

  def student_groups
    student_groups_for_table
  end

  private
  def prepare_data!
    @rating_groups = @exercise.rating_groups.rank(:row_order)
    @evaluation_groups_by_student_groups_and_rating_groups = Hash.new {|h,k| h[k] = Hash.new}
    @evaluations_by_student_groups_and_ratings = Hash.new {|h,k| h[k] = Hash.new}
    @submissions_by_student_groups = Hash.new

    @exercise.submissions.each do |submission|
      if (sg = submission.student_group) && (student_groups_for_table.include? submission.student_group)
        @submissions_by_student_groups[sg] = submission

        if (se = submission.submission_evaluation)
          se.evaluation_groups.each do |evaluation_group|
            @evaluation_groups_by_student_groups_and_rating_groups[sg][evaluation_group.rating_group] = evaluation_group

            evaluation_group.evaluations.each do |evaluation|
              @evaluations_by_student_groups_and_ratings[sg][evaluation.rating] = evaluation
            end
          end
        end
      end
    end
  end

  def student_groups_for_table
    @student_groups ||= begin
      if @tutorial_group
        student_groups = @tutorial_group.student_groups
      else
        student_groups = @exercise.term.student_groups
      end.includes(student_registrations: :student).where {solitary != my {@exercise.group_submission?}}.order(:title).load
    end
  end
end
