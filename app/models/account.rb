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
  has_many :tutorial_groups, through: :tutor_registrations

  has_many :student_groups, through: :student_registrations
  has_many :student_group_registrations, through: :student_groups
  has_many :submissions, through: :student_group_registrations
  has_many :term_registrations

  serialize :options

  scope :search, lambda {|query|
    rel = scoped

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

  def points_for_term(term)
    @points_for_term ||= {}
    @points_for_term[term.id] ||= student_groups.for_term(term).map(&:points).compact.sum
  end

  def grade_for_term(term)
    if term.participated? self
      submissions = Submission.for_account(self)

      term.exercises.each do |exercise|
        submission = submissions.for_exercise(exercise).last

        if exercise.enable_min_required_points && (submission.nil? || submission.submission_evaluation.evaluation_result < exercise.min_required_points)
          # assumes that the negative grade (term not passed) is first one
          return term.grading_scale.first[1]
        end
      end


      @grade_for_term ||= {}
      @grade_for_term[term.id] ||= term.grade_for_points(points_for_term(term))
    else
      "0"
    end
  end

  def tutorial_group_for_term(term)
    student_group = student_groups.joins(:tutorial_group).where(tutorial_group: {term: term}).first
    student_group.tutorial_group
  end

###############################################################################


  def lecturer_of_term?(term)
    lecturer_registrations
      .where{term_id == my{term.id}}
      .exists?
  end

  def lecturer_of_any_term_in_course?(course)
    lecturer_registrations
      .joins{term}
      .where{term.id.in my{course.terms.pluck(:id)}}
      .exists?
  end

  def tutor_of_term?(term)
    tutor_registrations
      .joins{tutorial_group.term}
      .where{tutorial_group.term == my{term}}
      .exists?
  end

  def student_of_term?(term)
    @student_of_term ||= Hash.new do |h,k|
      h[k] = student_registrations
        .joins {tutorial_group.term}
        .where {tutorial_group.term == my {k}}
        .exists?
      end
    @student_of_term[term]
  end

  def tutor_of_tutorial_group?(tutorial_group)
    if tutorial_group.tutor
      tutorial_group.tutor == self
    else
      false
    end
  end

  def tutor_of_any_tutorial_group_in_term?(term)
    tutor_registrations
      .joins{tutorial_group.term}
      .where{tutorial_group.term.id.in my{term.tutorial_groups.pluck(:id)}}
      .exists?
  end
end
