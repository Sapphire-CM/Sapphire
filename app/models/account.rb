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
  validates :matriculation_number, uniqueness: true, format: { with: /\A[\d]{7}\z/ }, if: :matriculation_number?
  validate :validate_no_email_address_with_same_email_exists

  scope :search, lambda {|query|
    rel = all

    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where { (forename =~ part) | (surname =~ part) | (matriculation_number =~ part) | (email =~ part) }
    end

    rel
  }

  %i(students tutors lecturers).each do |group|
    scope "#{group}_for_term".to_sym, lambda { |term| joins(:term_registrations).where(term_registrations: { term_id: term.id }).merge(TermRegistration.send(group)) }
  end

  scope :admins, lambda { where(admin: true) }

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

  def lecturer_of_term?(term)
    term_registrations.lecturers.where(term_id: term.id).exists?
  end

  def lecturer_of_any_term_in_course?(course)
    term_registrations.lecturers.where(term_id: course.terms.pluck(:id)).any?
  end

  def tutor_of_term?(term)
    term_registrations.tutors.where(term_id: term.id).exists?
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
