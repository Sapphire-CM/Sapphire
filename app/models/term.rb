class Term < ActiveRecord::Base
  belongs_to :course

  include RankedModel
  ranks :row_order, with_same: :course_id

  default_scope { rank(:row_order) }

  serialize :grading_scale, Array

  has_many :exercises, dependent: :destroy
  has_many :tutorial_groups, dependent: :destroy
  has_many :submissions, through: :exercises

  has_many :student_groups, through: :tutorial_groups

  has_one :lecturer_registration, dependent: :destroy
  delegate :lecturer, to: :lecturer_registration, allow_nil: true

  validates_presence_of :title, :course_id
  validates_uniqueness_of :title, scope: :course_id

  has_many :student_imports, dependent: :destroy, class_name: "Import::StudentImport"

  before_save :improve_grading_scale

  before_save :improve_points

  def self.associated_with(account)
    where {
      (id.in(my {account.student_registrations.joins(student_group: :tutorial_group).pluck(tutorial_groups: :term_id)})) |
      (id.in(my {account.tutor_registrations.joins(:tutorial_group).pluck(tutorial_groups: :term_id) })) |
      (id.in(my {account.lecturer_registrations.pluck(:term_id)}))
    }
  end

  def associated_with?(account)
    Term.associated_with(account).where(id: self.id).exists?
  end

  def improve_grading_scale
    self.grading_scale = {
       0 => '5',
      51 => '4',
      64 => '3',
      80 => '2',
      90 => '1'
    }.to_a if self.grading_scale.empty?

    self.grading_scale.sort!

    self.grading_scale.dup.reverse.each_with_index do |scale, index|
      self.grading_scale[index][1] = "#{grading_scale.length - index}"
    end

    self.grading_scale
  end

  def improve_points
    self.points ||= 0
  end

  def update_points!
    self.points = exercises.pluck(:points).compact.sum || 0
    self.save!
  end

  def tutors
    @tutors ||= Account.joins(tutor_registrations: {tutorial_group: :term}).where{ tutor_registrations.tutorial_group.term.id == my{id}}
  end

  def students
    @students ||= Account.joins(student_registrations: {tutorial_group: :term}).where{ student_registrations.tutorial_group.term.id == my{id}}
  end

  def group_submissions?
    @group_submission ||= exercises.where(group_submission: true).exists?
  end

  def copy_lecturer(destination_term)
    source_registration = LecturerRegistration.find_by_term_id(self.id)

    if source_registration
      registration = LecturerRegistration.find_or_initialize_by(term_id: destination_term.id)
      registration.lecturer = source_registration.lecturer
      registration.save!
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
          exercise.save!
        end
      end
    end

    RatingGroup.uncached do
      RatingGroup.transaction do
        rating_groups.each do |rating_group|
          rating_group.exercise = rating_group.exercise # refresh exercise_id
          rating_group.save!
        end
      end
    end

    Rating.uncached do
      Rating.transaction do
        ratings.each do |rating|
          rating.rating_group = rating.rating_group # refresh rating_group_id
          rating.save!
        end
      end
    end
  end

  def copy_grading_scale(destination_term)
    destination_term.grading_scale = self.grading_scale.dup
    destination_term.save!
  end

  def grade_for_points(points)
    @grade_for_points ||= {}
    @grade_for_points[points] ||= grading_scale.select{|lower, grade| lower <= points}.last[1]
  end

  def grade_distribution(students)
    distribution = Hash.new(0)
    grades = students.map{|s| s.grade_for_term(self)}

    grades.each do |v|
      distribution[v] += 1
    end
    distribution
  end

  def participated?(student)
    @values ||= begin
      values = {}

      exercises.each do |ex|
        students.each do |s|
          values[s.id] ||= {}
          values[s.id] = s.submissions_for_term(self).any?
        end
      end

      values
    end

    @values[student.id]
  end


  def update_grading_scale!(new_grading_scale)
    self.grading_scale.map! do |scale|
      if (scale_to_update = new_grading_scale.select { |param| scale.last == param.last}).any?
        scale_to_update.first
      else
        scale
      end
    end
    self.save!
  end
end
