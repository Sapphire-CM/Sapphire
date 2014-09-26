class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  has_one :course, through: :term

  default_scope { includes(:tutor_term_registrations).order(:title) }

  has_many :result_publications, dependent: :destroy
  has_many :student_groups, dependent: :destroy

  has_many :term_registrations
  has_many :student_term_registrations, lambda { students }, source: :term_registrations, class_name: "TermRegistration"
  has_many :tutor_term_registrations, lambda { tutors }, source: :term_registrations, class_name: "TermRegistration"

  has_many :registered_accounts, through: :term_registrations, class_name: "Account", source: :account
  has_many :student_accounts, through: :student_term_registrations, class_name: "Account", source: :account
  has_many :tutor_accounts, through: :tutor_term_registrations, class_name: "Account", source: :account

  after_create :ensure_result_publications

  validates_presence_of :title
  validates_uniqueness_of :title, scope: :term_id

  def student_has_submission_for_exercise?(student, exercise)
    @values ||= begin
      values = {}

      term.exercises.each do |ex|
        students.each do |s|
          values[s.id] ||= {}
          values[s.id][ex.id] = s.submission_for_exercise(ex).any?
        end
      end

      values
    end

    @values[student.id][exercise.id]
  end

  def results_published_for?(exercise)
    exercise.result_published_for?(self)
  end

  def all_results_published?
    !result_publications.concealed.where(exercise_id: term.exercises.pluck(:id)).exists?
  end

  private
  def ensure_result_publications
    term.exercises.each do |exercise|
      ResultPublication.create(tutorial_group: self, exercise: exercise)
    end
  end
end
