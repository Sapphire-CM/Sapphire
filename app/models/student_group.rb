# create_table :student_groups, force: :cascade do |t|
#   t.string   :title,             limit: 255
#   t.integer  :tutorial_group_id
#   t.datetime :created_at,                    null: false
#   t.datetime :updated_at,                    null: false
#   t.integer  :points
#   t.string   :keyword
#   t.string   :topic
#   t.text     :description
# end
#
# add_index :student_groups, [:tutorial_group_id], name: :index_student_groups_on_tutorial_group_id, using: :btree

class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group, inverse_of: :student_groups

  has_one :term, through: :tutorial_group
  has_many :term_registrations, dependent: :nullify
  has_many :students, through: :term_registrations, class_name: 'Account', source: :account
  has_many :submissions, dependent: :nullify
  has_many :submission_evaluations, through: :submissions

  scope :for_term, lambda { |term| joins { tutorial_group.term }.where { tutorial_group.term.id == my { term.id } } }
  scope :for_tutorial_group, lambda { |tutorial_group| where(tutorial_group_id: tutorial_group.id) }
  scope :for_account, lambda { |account| joins(:term_registrations).where(term_registrations: {account: account}) }

  validates :title, presence: true
  validates :tutorial_group_id, presence: true

  after_save :update_term_registrations_tutorial_group

  def update_points!
    self.points = submission_evaluations.pluck(:evaluation_result).sum
    self.save!
  end

  private
  def update_term_registrations_tutorial_group
    term_registrations.where.not(tutorial_group: tutorial_group).each do |term_registration|
      term_registration.update(tutorial_group: tutorial_group)
    end
  end
end
