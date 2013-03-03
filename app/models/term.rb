class Term < ActiveRecord::Base
  belongs_to :course
  
  has_many :exercises, :dependent => :destroy
  has_many :tutorial_groups, :dependent => :destroy

  has_one :lecturer_registrations, :dependent => :destroy
  delegate :lecturer, :to => :lecturer_registrations
  
  attr_accessible :title, :description, :course, :course_id, :exercises
  
  validates_presence_of :title, :course_id
  validates_uniqueness_of :title
  
  has_many :student_imports, :dependent => :destroy, :class_name => "Import::StudentImport"

  def tutors
    tmp = []

    tutorial_groups.each do |tutorial_group|
      tmp << tutorial_group.tutor
    end

    tmp
  end

  def students
    tmp = []

    tutorial_groups.each do |tutorial_group|
      tutorial_group.student_registrations.each do |registration|
        tmp << registration.student
      end
    end

    tmp
  end
end
