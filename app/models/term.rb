class Term < ActiveRecord::Base
  belongs_to :course
  attr_accessible :title, :description, :course, :course_id, :exercises, :grading_scale

  include RankedModel
  ranks :row_order, with_same: :course_id

  default_scope { rank(:row_order) }

  serialize :grading_scale, Array

  has_many :exercises, dependent: :destroy
  has_many :tutorial_groups, dependent: :destroy

  has_many :submissions, through: :exercises

  has_one :lecturer_registration, dependent: :destroy
  delegate :lecturer, to: :lecturer_registration, allow_nil: true

  validates_presence_of :title, :course_id
  validates_uniqueness_of :title, scope: :course_id

  has_many :student_imports, dependent: :destroy, class_name: "Import::StudentImport"

  before_save :improve_grading_scale

  def improve_grading_scale
    self.grading_scale = {
       0 => '5',
      51 => '4',
      64 => '3',
      80 => '2',
      90 => '1'
    }.to_a if self.grading_scale.empty?

    self.grading_scale.sort!
  end

  def update_points!
    self.points = exercises.pluck(:points).compact.inject(:+) || 0
    self.save!
  end

  def tutors
    Account.joins(tutor_registrations: {tutorial_group: :term}).where{ tutor_registrations.tutorial_group.term.id == my{id}}
  end

  def students
    Account.joins(student_registrations: {tutorial_group: :term}).where{ student_registrations.tutorial_group.term.id == my{id}}
  end

  def group_submissions?
    exercises.where(group_submission: true).exists?
  end

  def copy_lecturer(destination_term)
    source_registration = LecturerRegistration.find_by_term_id(self.id)

    if source_registration
      registration = LecturerRegistration.find_or_initialize_by_term_id(destination_term.id)
      registration.lecturer = source_registration.lecturer
      registration.registered_at = DateTime.now
      registration.save
    end
  end

  def copy_exercises(destination_term)
    exercises = []
    rating_groups = []
    ratings = []

    self.exercises.each do |source_exercise|
      exercise = source_exercise.dup
      exercise.term = destination_term
      exercises << exercise

      source_exercise.rating_groups.each do |source_rating_group|
        rating_group = source_rating_group.dup
        rating_group.exercise = exercise
        rating_groups << rating_group

        source_rating_group.ratings.each do |source_rating|
          rating = source_rating.dup
          rating.rating_group = rating_group
          ratings << rating
        end
      end
    end

    Exercise.uncached do
      Exercise.transaction do
        exercises.each do |exercise|
          exercise.save
        end
      end
    end

    RatingGroup.uncached do
      RatingGroup.transaction do
        rating_groups.each do |rating_group|
          rating_group.exercise = rating_group.exercise # refresh exercise_id
          rating_group.save
        end
      end
    end

    Rating.uncached do
      Rating.transaction do
        ratings.each do |rating|
          rating.rating_group = rating.rating_group # refresh rating_group_id
          rating.save
        end
      end
    end
  end

  def copy_grading_scale(destination_term)
    destination_term.grading_scale = self.grading_scale.dup
    destination_term.save
  end

  def get_grade(points)
    grading_scale.select{|lower, grade| lower <= points}.last[1]
  end

end
