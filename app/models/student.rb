class Student < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :submission_group
  attr_accessible :email, :forename, :matriculum_number, :registration_date, :surname
  
  has_many :term_registrations, :dependent => :destroy
  has_many :tutorial_groups, :through => :term_registrations
  
  scope :for_term, lambda {|term| joins(:term_registrations).where{term_registrations.term_id == term}}
  
  def self.search(query)
    rel = scoped 
    
    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculum_number=~ part)}
    end
    
    rel
  end
end
