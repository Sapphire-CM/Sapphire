class TermCopyingService
  include ActiveModel::Model

  attr_accessor :term

  def self.copy_async(term)
    options = {
      lecturers: term.copy_lecturer?,
      exercises: term.copy_exercises?,
      grading_scale: term.copy_grading_scale?
    }

    TermCopyWorker.perform_async(term.id, term.source_term_id, options)
  end

  def initialize(term, source_term, options = {})
    @term = term
    @source_term = source_term
    @options = options

    @copy_lecturers = @options[:lecturers] || false
    @copy_exercises = @options[:exercises] || false
    @copy_grading_scale = @options[:grading_scale] || false
  end

  def perform!
    ActiveRecord::Base.transaction do
      copy_lecturers! if @copy_lecturers
      copy_exercises! if @copy_exercises
      copy_grading_scale! if @copy_grading_scale
    end
  end

  private
  def copy_lecturers!
    puts "Copying Lecturer"
    @source_term.term_registrations.lecturers.each do |lecturer_registration|
      TermRegistration.create!(term: @term, account: lecturer_registration.account, role: TermRegistration::LECTURER)
    end
  end

  def copy_exercises!
    puts "Copying Exercises"
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

  def copy_grading_scale!
    puts "Copying Grading Scale"
    @term.grading_scale = @source_term.grading_scale.dup
  end
end