class Account < ActiveRecord::Base
  DEFAULT_PASSWORD = "sapphire%{matriculation_number}"

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :forename, :surname, :matriculation_number

  # devise already does this with the validatable-option: validates_uniqueness_of :email
  validates_presence_of :forename
  validates_presence_of :surname

  validates_uniqueness_of :matriculation_number, if: :matriculation_number?
  validates_format_of :matriculation_number, with: /\A[\d]{7}\z/, if: :matriculation_number?

  has_many :lecturer_registrations, dependent: :destroy
  has_many :tutor_registrations, dependent: :destroy
  has_many :student_registrations, dependent: :destroy
  has_many :tutorial_groups, through: :tutor_registrations

  has_many :student_groups, through: :student_registrations
  has_many :student_group_registrations, through: :student_groups
  has_many :submissions, through: :student_group_registrations

  serialize :options

  def initialize(*args)
    super *args
    self.options ||= Hash.new
  end

  def fullname
    @fullname ||= "#{forename} #{surname}"
  end

  def reverse_fullname
    @reverse_fullname ||= "#{surname} #{forename}"
  end

  def submissions_for_term(term)
    @submissions_for_term ||= {}
    @submissions_for_term[term.id] ||= submissions.for_term term
  end

  def submission_for_exercise(exercise)
    @submission_for_exercise ||= {}
    @submission_for_exercise[exercise.id] ||= submissions.for_exercise exercise
  end

  def points_for_term(term)
    @points_for_term ||= {}
    @points_for_term[term.id] ||= student_groups.for_term(term).map(&:points).compact.sum
  end

  def grade_for_term(term)
    if term.participated? self
      @grade_for_term ||= {}
      @grade_for_term[term.id] ||= term.grade_for_points(points_for_term(term))
    else
      "0"
    end
  end

  def self.search(query)
    rel = scoped

    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculation_number=~ part) | (email=~ part)}
    end

    rel
  end
end
