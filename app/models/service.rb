# create_table :services, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.boolean  :active,                  default: false, null: false
#   t.string   :type,        limit: 255
#   t.text     :properties
#   t.datetime :created_at,                              null: false
#   t.datetime :updated_at,                              null: false
# end

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
