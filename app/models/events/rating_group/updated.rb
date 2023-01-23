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

module Events
  module RatingGroup
    class Updated < ::Event
      data_reader :exercise_title, :exercise_id, :rating_group_title, :rating_group_id, :points

      def tracked_changes
        data[:changes].with_indifferent_access
      end
    end
  end
end
