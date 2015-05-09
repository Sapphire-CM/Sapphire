class Event < ActiveRecord::Base
  include SerializableHash

  belongs_to :subject, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, :term, presence: true

  scope :for_term, lambda {|term| where(term: term) }
  scope :time_ordered, lambda { order(created_at: :desc) }

  serialize_hash :data

  def to_partial_path
    self.class.to_s.underscore
  end
end
