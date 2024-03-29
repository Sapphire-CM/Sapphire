# create_table :events, force: :cascade do |t|
#   t.string   :type
#   t.string   :subject_type, null: false
#   t.integer  :subject_id,   null: false
#   t.integer  :account_id,   null: false
#   t.integer  :term_id,      null: false
#   t.text     :data
#   t.datetime :created_at,   null: false
#   t.datetime :updated_at,   null: false
#   t.index [:account_id], name: :index_events_on_account_id
#   t.index [:subject_type, :subject_id], name: :index_events_on_subject_type_and_subject_id
# end

class Event < ActiveRecord::Base
  include SerializableHash

  belongs_to :subject, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, :term, presence: true

  scope :for_term, lambda { |term| where(term: term) }
  scope :time_ordered, lambda { order(updated_at: :desc) }

  serialize_hash :data

  def self.data_reader(*args)
    args.each do |arg|
      define_method(arg) do
        data[arg]
      end
    end
  end

  def self.data_writer(*args)
    args.each do |arg|
      define_method("#{arg}=") do |value|
        data[arg] = value
        serialize_data!
        value
      end
    end
  end

  def to_partial_path
    self.class.to_s.underscore
  end
end
