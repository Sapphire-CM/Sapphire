class Service < ActiveRecord::Base
  include SerializedProperties

  belongs_to :exercise

  has_one :term, through: :exercise

  validates_presence_of :exercise_id
  validates_exclusion_of :type, in: %w( Service )
  scope :active, lambda { where(active: true) }

  def self.service_classes
    [NewsgroupFetcherService, WebsiteFetcherService]
  end

  def self.policy_class
    ServicePolicy
  end

  def title
    ''
  end

  def perform!
  end
end
