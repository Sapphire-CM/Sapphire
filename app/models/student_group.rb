# create_table :student_groups, force: :cascade do |t|
#   t.string   :title
#   t.integer  :tutorial_group_id
#   t.datetime :created_at,        null: false
#   t.datetime :updated_at,        null: false
#   t.integer  :points
# end
#
# add_index :student_groups, [:tutorial_group_id], name: :index_student_groups_on_tutorial_group_id

class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group, inverse_of: :student_groups

  has_one :term, through: :tutorial_group
  has_many :term_registrations, dependent: :nullify
  has_many :students, through: :term_registrations, class_name: 'Account', source: :account
  has_many :submissions, dependent: :nullify
  has_many :submission_evaluations, through: :submissions

  scope :for_term, lambda { |term| joins { tutorial_group.term }.where { tutorial_group.term.id == my { term.id } } }
  scope :for_tutorial_group, lambda { |tutorial_group| where(tutorial_group_id: tutorial_group.id) }

  validates :title, presence: true
  validates :tutorial_group_id, presence: true

  def update_points!
    self.points = submission_evaluations.pluck(:evaluation_result).sum
    self.save!
  end
end
