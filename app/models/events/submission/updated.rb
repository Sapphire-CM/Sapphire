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
  module Submission
    class Updated < ::Event
      data_reader :submission_assets, :exercise_title, :exercise_id, :path, :submission_id
      data_writer :submission_assets

      scope :recent, lambda { where(arel_table[:updated_at].gt(30.minutes.ago)) }

      def self.recent_for_submission(submission)
        where(subject: submission).recent.first
      end


      def only_additions?
        submission_assets[:added].any? && submission_assets[:updated].empty? && submission_assets[:destroyed].empty?
      end

      def only_updates?
        submission_assets[:added].empty? && submission_assets[:updated].any? && submission_assets[:destroyed].empty?
      end

      def only_removals?
        submission_assets[:added].empty? && submission_assets[:updated].empty? && submission_assets[:destroyed].any?
      end

      def additions
        submission_assets[:added]
      end

      def updates
        submission_assets[:updated]
      end

      def removals
        submission_assets[:destroyed]
      end
    end
  end
end
