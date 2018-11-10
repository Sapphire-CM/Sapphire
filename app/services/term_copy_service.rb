class TermCopyService
  attr_accessor :term, :source_term, :copy_lecturers, :copy_exercises, :copy_grading_scale

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
      @term.preparing!
      copy_lecturers! if @copy_lecturers
      copy_exercises! if @copy_exercises
      copy_grading_scale! if @copy_grading_scale
      @term.ready!
    end
  end

  private

  def copy_lecturers!
    Rails.logger.info 'Copying Lecturer'
    @source_term.term_registrations.lecturers.each do |lecturer_registration|
      TermRegistration.create!(term: @term, account: lecturer_registration.account, role: TermRegistration::LECTURER)
    end
  end

  def copy_exercises!
    Rails.logger.info 'Copying Exercises'
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
    Rails.logger.info 'Copying Grading Scale'
    @source_term.grading_scales.each do |source_grading_scale|
      source_attributes = source_grading_scale.attributes.except("id", "term_id", "created_at", "updated_at")

      grading_scale = @term.grading_scales.find_or_initialize_by(grade: source_grading_scale.grade)
      grading_scale.update(source_attributes)
    end
  end
end
