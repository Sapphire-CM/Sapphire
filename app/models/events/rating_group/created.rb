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
# add_index :events, [:account_id], name: :index_events_on_account_id, using: :btree
# add_index :events, [:subject_type, :subject_id], name: :index_events_on_subject_type_and_subject_id, using: :btree

module Events
  module RatingGroup
    class Created < ::Event
      data_reader :exercise_title, :exercise_id, :rating_group_title, :rating_group_id, :points
    end
  end
end
