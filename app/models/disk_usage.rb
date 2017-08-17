class DiskUsage < ActiveRecord::Base
	belongs_to :term

  has_one :course, through: :term

  validates :term, presence: true

	def index
	end

	def show
		authorize Account
	end

 	private
	
end