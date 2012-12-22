class TermRegistration < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :term
  belongs_to :student
  attr_accessible :registered_at
end
