class Term < ActiveRecord::Base
  belongs_to :course

  has_many :exercises, dependent: :destroy
  has_many :tutorial_groups, dependent: :destroy
  
  has_many :submissions, through: :exercises

  has_one :lecturer_registration, dependent: :destroy
  delegate :lecturer, to: :lecturer_registration, allow_nil: true

  attr_accessible :title, :description, :course, :course_id, :exercises

  validates_presence_of :title, :course_id
  validates_uniqueness_of :title, scope: :course_id

  has_many :student_imports, dependent: :destroy, class_name: "Import::StudentImport"

  def tutors
    Account.joins(tutor_registrations: {tutorial_group: :term}).where{ tutor_registrations.tutorial_group.term.id == my{id}}
  end

  def students
    Account.joins(student_registrations: {tutorial_group: :term}).where{ student_registrations.tutorial_group.term.id == my{id}}
  end

end
