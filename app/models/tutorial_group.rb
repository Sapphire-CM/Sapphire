class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  has_one :course, through: :term
  attr_accessible :title, :description

  default_scope { includes(:tutor_registration) }

  validates_presence_of :title
  validates_uniqueness_of :title, scope: :term_id

  has_one :tutor_registration, dependent: :destroy
  delegate :tutor, to: :tutor_registration, allow_nil: true

  has_many :student_groups, dependent: :destroy

  has_many :submissions, through: :student_group_registrations

  def students
    student_groups.flat_map { |sg| sg.students }.uniq
  end
end
