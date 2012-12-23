class TermRegistration < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :term
  belongs_to :student
  has_one :course, :through => :term
  
  attr_accessible :registered_at
  
  scope :with_students, joins(:student).includes(:student)
  scope :with_tutorial_groups, joins(:tutorial_group).includes(:tutorial_group)
  scope :with_terms, joins(:term).includes(:term)
  scope :with_courses, joins(:term => :course).includes(:term => :course)
  scope :for_tutorial_group, lambda {|tutorial_group|  where{tutorial_group_id == tutorial_group}}
  
  # def self.search(query)
  #   rel = scoped.joins(:student)
  #   
  #   query.split(/\s+/).each do |part|
  #     part = "%#{part}%"
  #     rel = rel.where {(student.forename =~ part) | (student.surname =~ part) | (student.matriculum_number=~ part) | (student.email=~ part)}
  #   end
  #   
  #   rel
  # end
  
  def self.search(query)
    scoped.merge(Student.search(query))
  end
end
