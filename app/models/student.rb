class Student < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :submission_group
  attr_accessible :email, :forename, :matriculum_number, :registration_date, :surname
  
  has_many :term_registrations, :dependent => :destroy
end
