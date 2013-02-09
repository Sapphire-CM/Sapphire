class Student < ActiveRecord::Base
  belongs_to :tutorial_group
  belongs_to :submission_group
  attr_accessible :email, :forename, :matriculum_number, :surname
  
  has_many :term_registrations, :dependent => :destroy
  has_many :tutorial_groups, :through => :term_registrations
  has_many :evalutions, :dependent => :destroy
  
  validates_presence_of :forename, :surname, :email, :matriculum_number
  validates_uniqueness_of :matriculum_number, :email, :message => "is already present"
  validates_format_of :matriculum_number, :with => /^[\d]{7}$/
  
  scope :for_term, lambda {|term| joins(:term_registrations).where{term_registrations.term_id == term}}
  
  def self.search(query)
    rel = scoped 
    
    query.split(/\s+/).each do |part|
      part = "%#{part}%"
      rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculum_number=~ part) | (email=~ part)}
    end
    
    rel
  end
end
