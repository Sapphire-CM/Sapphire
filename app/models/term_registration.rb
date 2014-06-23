class TermRegistration < ActiveRecord::Base
  include Roles

  belongs_to :account
  belongs_to :term
  belongs_to :tutorial_group

  has_many :exercise_registrations
  has_many :exercises, -> { uniq }, through: :exercise_registrations

  validates_presence_of :account_id, :term_id, :role
  validates_inclusion_of :role, :in => Roles::ALL
  validates_uniqueness_of :account_id, scope: :term_id
  validates_presence_of :tutorial_group_id, unless: :lecturer?
  validates_absence_of :tutorial_group_id, if: :lecturer?

  scope :positive_grades, lambda { where(positive_grade: true) }
  scope :negative_grades, lambda { where(positive_grade: false) }

  scope :ordered_by_matriculation_number, lambda { joins(:account).order{ account.matriculation_number.asc } }

  sifter :positive_grades do
    positive_grade == true
  end

  sifter :negative_grades do
    positive_grade == false
  end

  Roles::ALL.each do |role|
    scope role.to_s.pluralize.to_sym, lambda { where(role: role.to_s) }
  end

  def update_points
    self.points = exercise_registrations.sum(:points)
    self.positive_grade = positive_grade_archived?
  end

  def update_points!
    update_points
    save!
  end

  def negative_grade?
    !positive_grade?
  end

  def all_minimum_points_reached?
    exercise_registrations.find {|exercise_registration| !exercise_registration.minimum_points_reached? } .blank?
  end

  def all_exercises_submitted?
    term.exercises.count == exercises.count
  end

  def positive_grade_archived?
    all_minimum_points_reached? && all_exercises_submitted?
  end
end
