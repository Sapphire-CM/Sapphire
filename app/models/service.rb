class Service < ActiveRecord::Base
  include SerializedProperties

  belongs_to :exercise

  has_one :term, through: :exercise

  validates :exercise_id, presence: true
  validates :type, exclusion: { in: %w(Service) }

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
