class Account < ActiveRecord::Base
  DEFAULT_PASSWORD = "sapphire%{matriculum_number}"

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :forename, :surname, :matriculum_number

  # devise already does this with the validatable-option: validates_uniqueness_of :email
  validates_presence_of :forename
  validates_presence_of :surname

  validates_uniqueness_of :matriculum_number, if: :matriculum_number?
  validates_format_of :matriculum_number, with: /\A[\d]{7}\z/, if: :matriculum_number?

  has_many :lecturer_registrations, dependent: :destroy
  has_many :tutor_registrations, dependent: :destroy
  has_many :student_registrations, dependent: :destroy
  has_many :tutorial_groups, through: :tutor_registrations

  has_many :submissions, through: :student_registrations
  has_many :student_groups, through: :student_registrations

  serialize :options

  def initialize(*args)
    super *args
    self.options ||= Hash.new
  end

  def fullname
    "#{forename} #{surname}"
  end

  def submissions_for_term(term)
    submissions.for_term term
  end

  def points_for_term(term)
    student_groups.for_term(term).map(&:points).sum
  end

  def grade_for_term(term)
    term.grade_for_points points_for_term(term)
  end

  def self.search(query)
    rel = scoped

    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculum_number=~ part) | (email=~ part)}
    end

    rel
  end
end
