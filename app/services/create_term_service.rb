class CreateTermService
  include ActiveModel::Model

  attr_accessor :term

  def initialize(term)
    @term = term
    @source_term = term.course.terms.find(term.source_term_id)
  end

  def perform!
    copy_lecturers! if @term.copy_lecturer?
    copy_exercises! if @term.copy_exercises?
    copy_grading_scale! if @term.copy_grading_scale?
  end

  private
  def copy_lecturers!
    puts "Copying Lecturer"
    @source_term.lecturers.each do |lecturer|
      TermRegistration.create!(term: @term, account: lecturer, role: TermRegistration::LECTURER)
    end
  end

  def copy_exercises!
    puts "Copying Exercises"
    ActiveRecord::Base.transaction do
      @source_term.exercises.includes(rating_groups: :ratings).each do |source_exercise|
        exercise = source_exercise.dup
        exercise.term = @term
        exercise.save!

        source_exercise.rating_groups.each do |source_rating_group|
          rating_group = source_rating_group.dup
          rating_group.exercise = exercise
          rating_group.save!

          source_rating_group.ratings.each do |source_rating|
            rating = source_rating.dup
            rating.rating_group = rating_group
            rating.save!
          end
        end
      end
    end
  end

  def copy_grading_scale!
    puts "Copying Grading Scale"
    @term.grading_scale = @source_term.grading_scale.dup
  end
end