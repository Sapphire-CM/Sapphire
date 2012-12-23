class TermRegistration < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :term
  belongs_to :student
  
  attr_accessible :registered_at
  
  scope :with_students, joins(:student).includes(:student)
  scope :with_tutorial_groups, joins(:tutorial_group).includes(:tutorial_group)
  scope :for_tutorial_group, lambda {|tutorial_group|  where{tutorial_group_id == tutorial_group}}
end
