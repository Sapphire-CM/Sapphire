class Account < ActiveRecord::Base
  DEFAULT_PASSWORD = "sapphire%{matriculation_number}"

  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable

  # devise already does this with the validatable-option: validates_uniqueness_of :email
  validates_presence_of :forename
  validates_presence_of :surname

  validates_uniqueness_of :matriculation_number, if: :matriculation_number?
  validates_format_of :matriculation_number, with: /\A[\d]{7}\z/, if: :matriculation_number?

  has_many :lecturer_registrations, dependent: :destroy
  has_many :tutor_registrations, dependent: :destroy
  has_many :student_registrations, dependent: :destroy

  has_many :student_groups, through: :student_registrations
  has_many :student_group_registrations, through: :student_groups
  has_many :submissions, through: :student_group_registrations
  has_many :term_registrations
  has_many :tutorial_groups, through: :term_registrations

  serialize :options

  scope :search, lambda {|query|
    rel = all

    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculation_number=~ part) | (email=~ part)}
    end

    rel
  }

  %i(students tutors lecturers).each do |group|
    scope "#{group}_for_term".to_sym, lambda {|term| joins(:term_registrations).where(term_registrations: {term_id: term.id}).merge(TermRegistration.send(group)) }
  end

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

  def tutorial_group_for_term(term)
    student_group = student_groups.joins(:tutorial_group).where(tutorial_group: {term: term}).first
    student_group.tutorial_group
  end

  def default_password
    DEFAULT_PASSWORD % {matriculation_number: self.matriculation_number}
  end


  def staff_of_term?(term)
    term_registrations.where(role: Roles::STAFF, term: term).exists?
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
end
