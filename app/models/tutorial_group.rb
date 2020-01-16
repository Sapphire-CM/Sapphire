# create_table :tutorial_groups, force: :cascade do |t|
#   t.string   :title
#   t.integer  :term_id
#   t.datetime :created_at,  null: false
#   t.datetime :updated_at,  null: false
#   t.text     :description
# end
#
# add_index :tutorial_groups, [:term_id], name: :index_tutorial_groups_on_term_id
# add_index :tutorial_groups, [:title, :term_id], name: :index_tutorial_groups_on_title_and_term_id, unique: true

class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  has_one :course, through: :term

  has_many :result_publications, dependent: :destroy
  has_many :student_groups, dependent: :destroy

  has_many :term_registrations, dependent: :destroy
  has_many :student_term_registrations, lambda { students }, source: :term_registrations, class_name: 'TermRegistration'
  has_many :tutor_term_registrations, lambda { tutors }, source: :term_registrations, class_name: 'TermRegistration'

  has_many :registered_accounts, through: :term_registrations, class_name: 'Account', source: :account
  has_many :student_accounts, through: :student_term_registrations, class_name: 'Account', source: :account
  has_many :tutor_accounts, through: :tutor_term_registrations, class_name: 'Account', source: :account

  after_create :ensure_result_publications

  validates :term, presence: true
  validates :title, presence: true, uniqueness: { scope: :term_id }

  scope :ordered_by_title, lambda { order(:title) }

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

  def graded_count
    term_registrations.where(receives_grade: true).count
  end

  def ungraded_count
    term_registrations.where(receives_grade: false).count
  end

  private

  def ensure_result_publications
    term.exercises.each do |exercise|
      ResultPublication.find_or_create_by(tutorial_group_id: id, exercise: exercise)
    end
  end
end
