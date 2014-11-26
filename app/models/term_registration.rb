class TermRegistration < ActiveRecord::Base
  include Roles

  belongs_to :account
  belongs_to :term
  belongs_to :tutorial_group

  has_many :exercise_registrations
  has_many :exercises, -> { uniq }, through: :exercise_registrations
  has_many :submissions, through: :exercise_registrations

  validates_presence_of :account_id, :term_id, :role
  validates_inclusion_of :role, :in => Roles::ALL
  validates_uniqueness_of :account_id, scope: :term_id
  validates_presence_of :tutorial_group_id, unless: :lecturer?
  validates_absence_of :tutorial_group_id, if: :lecturer?

  scope :positive_grades, lambda { where(positive_grade: true) }
  scope :negative_grades, lambda { where(positive_grade: false) }
  scope :staff, lambda { where(role: Roles::STAFF) }
  scope :with_accounts, lambda { includes(:account) }
  scope :for_account, lambda {|account| where(account_id: account.id)}
  scope :for_email_addresses, lambda {|emails| joins(:account).joins{account.email_addresses.outer}.where{accounts.email.in(my{ emails }) | email_addresses.email.in(my{ emails }) }}
  scope :ordered_by_matriculation_number, lambda { joins(:account).order{ account.matriculation_number.asc } }
  scope :ordered_by_name, lambda { joins(:account).order{ account.forename.asc }.order{ account.surname.asc } }

  sifter :positive_grades do
    positive_grade == true
  end

  sifter :negative_grades do
    positive_grade == false
  end

  Roles::ALL.each do |role|
    scope role.to_s.pluralize.to_sym, lambda { where(role: role.to_s) }
  end

  def self.search(query)
    all.joins(:account).merge(Account.search(query))
  end

  def update_points
    self.points = exercise_registrations.sum(:points)
    self.positive_grade = positive_grade_possible?
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

  def any_exercise_submitted?
    exercise_registrations.any?
  end

  def positive_grade_possible?
    all_minimum_points_reached? && any_exercise_submitted?
  end
end
