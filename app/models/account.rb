class Account < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :forename, :surname, :matriculum_number
  
  belongs_to :accountable, :polymorphic => true
  
  validates_uniqueness_of :accountable_id
  validates_uniqueness_of :email
  validates_presence_of :forename
  validates_presence_of :surname

  validates_uniqueness_of :matriculum_number, :if => :matriculum_number?
  validates_format_of :matriculum_number, :with => /\A[\d]{7}\z/, :if => :matriculum_number?

  def fullname
    "#{forename} #{surname}"
  end

end

  # has_many :tutorial_groups  
  # has_many :courses, :through => :tutorial_groups, :uniq => true

  # belongs_to :tutorial_group
  # belongs_to :submission_group
  
  # has_many :term_registrations, :dependent => :destroy
  # has_many :tutorial_groups, :through => :term_registrations
  # has_many :evalutions, :dependent => :destroy
  
  # def self.search(query)
  #   rel = scoped 
    
  #   query.split(/\s+/).each do |part|
  #     part = "%#{part}%"
  #     rel = rel.where {(forename =~ part) | (surname =~ part) | (matriculum_number=~ part) | (email=~ part)}
  #   end
    
  #   rel
  # end
