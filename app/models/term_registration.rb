# create_table :term_registrations, force: :cascade do |t|
#   t.integer  :points
#   t.boolean  :positive_grade,    default: false, null: false
#   t.integer  :account_id
#   t.integer  :term_id
#   t.integer  :tutorial_group_id
#   t.datetime :created_at,                        null: false
#   t.datetime :updated_at,                        null: false
#   t.boolean  :receives_grade,    default: false, null: false
#   t.integer  :role,              default: 0
#   t.integer  :student_group_id
#   t.datetime :welcomed_at
#   t.index [:account_id, :term_id], name: :index_term_registrations_on_account_id_and_term_id, unique: true
#   t.index [:account_id], name: :index_term_registrations_on_account_id
#   t.index [:points], name: :index_term_registrations_on_points
#   t.index [:positive_grade], name: :index_term_registrations_on_positive_grade
#   t.index [:student_group_id], name: :index_term_registrations_on_student_group_id
#   t.index [:term_id], name: :index_term_registrations_on_term_id
#   t.index [:tutorial_group_id], name: :index_term_registrations_on_tutorial_group_id
# end

class TermRegistration < ActiveRecord::Base
  include Roles

  belongs_to :account
  belongs_to :term
  belongs_to :tutorial_group
  belongs_to :student_group

  has_many :exercise_registrations, dependent: :destroy
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
  scope :for_email_addresses, lambda { |emails| joins(:account).where(account: Account.where(email: emails).or(Account.joins(:email_addresses).where(email_addresses: { email: emails }))) }

  scope :ordered_by_matriculation_number, lambda { joins(:account).merge(Account.order(:matriculation_number)) }
  scope :ordered_by_name, lambda { joins(:account).merge(Account.order(:forename, :surname)) }

  scope :welcomed, lambda { where.not(welcomed_at: nil) }
  scope :waiting_for_welcome, lambda { where(welcomed_at: nil) }

  delegate :title, to: :tutorial_group, prefix: true, allow_nil: true

  Roles::ALL.each do |role|
    scope role.pluralize.to_sym, lambda { send(role) }
  end

  def self.search(query)
    all.joins(:account).merge(Account.search(query))
  end

  def update_points
    self.points = exercise_registrations.active.sum(:points)
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
    !term.exercises.mandatory_exercises.where.not(id: exercise_registrations.select('exercise_id')).exists? &&
      exercise_registrations.active.all? { |exercise_registration| exercise_registration.minimum_points_reached? }
  end

  def positive_grade_possible?
    all_minimum_points_reached? && exercise_registrations.any?
  end

  def welcomed?
    welcomed_at.present?
  end

  private
  def validate_term_consistency
    errors.add(:term, 'is not consistent') if tutorial_group.present? && term != tutorial_group.term
  end
end
