# create_table :events, force: :cascade do |t|
#   t.string   :type
#   t.integer  :subject_id,   null: false
#   t.string   :subject_type, null: false
#   t.integer  :account_id,   null: false
#   t.integer  :term_id,      null: false
#   t.text     :data
#   t.datetime :created_at,   null: false
#   t.datetime :updated_at,   null: false
# end
#
# add_index :events, [:account_id], name: :index_events_on_account_id
# add_index :events, [:subject_type, :subject_id], name: :index_events_on_subject_type_and_subject_id

class Event < ActiveRecord::Base
  include SerializableHash

  belongs_to :subject, polymorphic: true
  belongs_to :account
  belongs_to :term

  validates :account, :term, presence: true

  scope :for_term, lambda { |term| where(term: term) }
  scope :time_ordered, lambda { order(updated_at: :desc) }

  def self.filter_by_scopes(scopes)
    type_service = EventTypeService.new
    all.where(type: type_service.types_for_scopes(scopes))
  end


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
