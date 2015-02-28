class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group, inverse_of: :student_groups

  has_one :term, through: :tutorial_group
  has_many :term_registrations, dependent: :nullify
  has_many :students, through: :term_registrations, class_name: "Account", source: :account
  has_many :submissions, dependent: :nullify

  scope :for_term, lambda { |term| joins{tutorial_group.term}.where{tutorial_group.term.id == my{term.id}} }
  scope :for_tutorial_group, lambda { |tutorial_group| where(tutorial_group_id: tutorial_group.id) }

  validates :title, presence: true
  validates :tutorial_group_id, presence: true

  def update_points!
    self.points = self.submission_evaluations.pluck(:evaluation_result).sum
    self.save!
  end
end
