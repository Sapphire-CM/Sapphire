# create_table :accounts, force: :cascade do |t|
#   t.string   :email,                       default: "",    null: false
#   t.string   :encrypted_password,          default: "",    null: false
#   t.string   :reset_password_token
#   t.datetime :reset_password_sent_at
#   t.datetime :remember_created_at
#   t.integer  :sign_in_count,               default: 0
#   t.datetime :current_sign_in_at
#   t.datetime :last_sign_in_at
#   t.string   :current_sign_in_ip
#   t.string   :last_sign_in_ip
#   t.datetime :created_at,                                  null: false
#   t.datetime :updated_at,                                  null: false
#   t.string   :forename
#   t.string   :surname
#   t.string   :matriculation_number
#   t.text     :options
#   t.integer  :failed_attempts,             default: 0
#   t.string   :unlock_token
#   t.datetime :locked_at
#   t.boolean  :admin,                       default: false, null: false
#   t.boolean  :comment_markdown_preference, default: false
#   t.index [:email], name: :index_accounts_on_email, unique: true
#   t.index [:reset_password_token], name: :index_accounts_on_reset_password_token, unique: true
# end

class Account < ActiveRecord::Base
  DEFAULT_PASSWORD = 'sapphire%{matriculation_number}'

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable

  has_many :term_registrations, dependent: :destroy
  has_many :tutorial_groups, through: :term_registrations
  has_many :email_addresses, dependent: :destroy

  serialize :options

  # devise already does this with the validatable-option: validates_uniqueness_of :email
  validates :forename, presence: true
  validates :surname, presence: true

  validates :matriculation_number, uniqueness: { allow_blank: true }, numericality: { allow_blank: true }, length: { in: 7..8, allow_blank: true }

  validate :validate_no_email_address_with_same_email_exists

  scope :search, lambda {|query|
    scopes = query.split(/\s+/).map do |part|
      matcher = "%#{part}%"
      [
        arel_table[:forename].matches(matcher),
        arel_table[:surname].matches(matcher),
        arel_table[:matriculation_number].matches(matcher),
        arel_table[:email].matches(matcher)
      ].reduce(&:or)
    end

    where(scopes.reduce(&:and))
  }

  %i(students tutors lecturers).each do |group|
    scope "#{group}_for_term".to_sym, lambda { |term| joins(:term_registrations).where(term_registrations: { term_id: term.id }).merge(TermRegistration.send(group)) }
  end

  scope :admins, lambda { where(admin: true) }
  scope :default_order, lambda { order(:forename, :surname)}

  after_initialize do
    self.options ||= {}
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

  def tutorial_group_for_term(term)
    student_group = student_groups.joins(:tutorial_group).find_by(tutorial_group: { term: term })
    student_group.tutorial_group
  end

  def default_password
    DEFAULT_PASSWORD % { matriculation_number: matriculation_number }
  end

  def staff_of_term?(term)
    term_registrations.staff.where(term: term).exists?
  end

  def staff_of_course?(course)
    term_registrations.staff.joins(:term).where(terms: { course: course} ).exists?
  end

  def staff_of_any_term?
    tutor_of_any_term? || lecturer_of_any_term?
  end

  def lecturer_of_term?(term)
    term_registrations.lecturers.where(term_id: term.id).exists?
  end

  def lecturer_of_any_term_in_course?(course)
    term_registrations.lecturers.joins(:term).where(terms: { course: course }).exists?
  end

  def lecturer_of_any_term?
    term_registrations.lecturers.exists?
  end

  def tutor_of_term?(term)
    term_registrations.tutors.where(term_id: term.id).exists?
  end

  def tutor_of_any_term?
    term_registrations.tutors.exists?
  end

  def student_of_term?(term)
    term_registrations.students.where(term_id: term.id).exists?
  end

  def tutor_of_tutorial_group?(tutorial_group)
    term_registrations.tutors.where(tutorial_group_id: tutorial_group.id).exists?
  end

  def associated_with_term?(term)
    term_registrations.where(term_id: term.id).exists?
  end

  private

  def validate_no_email_address_with_same_email_exists
    if EmailAddress.where(email: email).exists?
      errors.add(:email, 'has already been taken')
    end
  end
end
