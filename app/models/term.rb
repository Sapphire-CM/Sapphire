class Term < ActiveRecord::Base
  belongs_to :course

  has_many :exercises, dependent: :destroy
  has_many :tutorial_groups, dependent: :destroy

  has_many :submissions, through: :exercises

  has_one :lecturer_registration, dependent: :destroy
  delegate :lecturer, to: :lecturer_registration, allow_nil: true

  attr_accessible :title, :description, :course, :course_id, :exercises

  validates_presence_of :title, :course_id
  validates_uniqueness_of :title, scope: :course_id

  has_many :student_imports, dependent: :destroy, class_name: "Import::StudentImport"

  def tutors
    Account.joins(tutor_registrations: {tutorial_group: :term}).where{ tutor_registrations.tutorial_group.term.id == my{id}}
  end

  def students
    Account.joins(student_registrations: {tutorial_group: :term}).where{ student_registrations.tutorial_group.term.id == my{id}}
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
    self.exercises.each do |source_exercise|
      exercise = source_exercise.dup
      exercise.term = destination_term
      exercise.save

      source_exercise.rating_groups.each do |source_rating_group|
        rating_group = source_rating_group.dup
        rating_group.exercise = exercise
        rating_group.save

        source_rating_group.ratings.each do |source_rating|
          rating = source_rating.dup
          rating.rating_group = rating_group
          rating.save
        end
      end
    end
  end

end
