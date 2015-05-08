class TermRegistration < ActiveRecord::Base
  include Roles

  belongs_to :account
  belongs_to :term
  belongs_to :tutorial_group
  belongs_to :student_group

  has_many :exercise_registrations
  has_many :exercises, -> { uniq }, through: :exercise_registrations
  has_many :submissions, through: :exercise_registrations

  enum role: Roles::ALL

  validates :account, presence: true
  validates :account_id, uniqueness: { scope: :term_id }
  validates :term, presence: true
  validates :tutorial_group, presence: true, unless: :lecturer?
  validates :tutorial_group, absence: true, if: :lecturer?
  validates :student_group, absence: true, unless: :student?
  validate :validate_term_consistency

  scope :graded, lambda { where(receives_grade: true) }
  scope :ungraded, lambda { where(receives_grade: false) }

  scope :positive_grades, lambda { graded.where(positive_grade: true) }
  scope :negative_grades, lambda { graded.where(positive_grade: false) }

  scope :staff, lambda { where(role: Roles::STAFF.map { |r| roles[r] }) }
  scope :with_accounts, lambda { includes(:account) }
  scope :for_account, lambda { |account| where(account_id: account.id) }
  scope :for_email_addresses, lambda { |emails| joins(:account).joins { account.email_addresses.outer }.where { accounts.email.in(my { emails }) | email_addresses.email.in(my { emails }) } }
  scope :ordered_by_matriculation_number, lambda { joins(:account).order { account.matriculation_number.asc } }
  scope :ordered_by_name, lambda { joins(:account).order { account.forename.asc }.order { account.surname.asc } }

  sifter :positive_grades do
    positive_grade == true
  end

  sifter :negative_grades do
    positive_grade == false
  end

  Roles::ALL.each do |role|
    scope role.pluralize.to_sym, lambda { send(role) }
  end

  def self.search(query)
    all.joins(:account).merge(Account.search(query))
  end

  def update_points
    self.points = exercise_registrations.sum(:points)
    self.positive_grade = positive_grade_possible?
    self.receives_grade = exercise_registrations.any?
  end

  def update_points!
    update_points
    save!
  end

  def staff?
    STAFF.map { |r| send "#{r}?" }.any?
  end

  def negative_grade?
    !positive_grade?
  end

  def all_minimum_points_reached?
    !term.exercises.mandatory_exercises.where.not(id: exercise_registrations.unscoped.select('exercise_id')).exists? &&
      exercise_registrations.find { |exercise_registration| !exercise_registration.minimum_points_reached? } .blank?
  end

  def positive_grade_possible?
    all_minimum_points_reached? && exercise_registrations.any?
  end

  private

  def validate_term_consistency
    errors.add(:term, 'is not consistent') if tutorial_group.present? && term != tutorial_group.term
  end
end
