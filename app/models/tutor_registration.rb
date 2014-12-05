class TutorRegistration < ActiveRecord::Base
  belongs_to :tutor, class_name: "Account", foreign_key: "account_id"
  belongs_to :tutorial_group

  has_one :term, through: :tutorial_group
  has_one :course, through: :term

  validates :tutor, presence: true
  validates :tutorial_group, presence: true
end
