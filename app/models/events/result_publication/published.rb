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

module Events
  module ResultPublication
    class Published < ::Event
      data_reader :exercise_id, :exercise_title, :tutorial_group_id, :tutorial_group_title
    end
  end
end
