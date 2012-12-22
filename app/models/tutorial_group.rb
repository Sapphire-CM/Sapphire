class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  attr_accessible :title
end
