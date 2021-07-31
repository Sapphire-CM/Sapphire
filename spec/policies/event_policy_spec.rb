require 'rails_helper'

RSpec.describe EventPolicy do
  describe 'scoping' do
    let(:event_service) { EventService.new(account, term) }

    let(:term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:other_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group) }

    let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group, student_group: student_group) }
    let(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }
    let(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term) }

    let(:group_member_term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group, student_group: student_group) }
    let(:other_student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term, tutorial_group: tutorial_group) }

    let(:admin_account) { FactoryGirl.create(:account, :admin) }

    let(:student_account) { student_term_registration.account }
    let(:group_member_account) { group_member_term_registration.account }
    let(:other_student_account) { student_term_registration.account }

    let(:tutor_account) { tutor_term_registration.account }
    let(:lecturer_account) { lecturer_term_registration.account }

    let(:solitary_exercise) { FactoryGirl.create(:exercise, :with_ratings, term: term, group_submission: false) }
    let(:group_exercise) { FactoryGirl.create(:exercise, :with_ratings, term: term, group_submission: true) }
    let(:rating_group) { solitary_exercise.rating_groups.first }
    let(:rating) { rating_group.ratings.first }

    let(:student_solitary_submission) do
      s = FactoryGirl.create(:submission, exercise: solitary_exercise)
      s.submission_assets = FactoryGirl.create_list(:submission_asset, 3, submission: s)

      FactoryGirl.create(:exercise_registration, exercise: solitary_exercise, term_registration: student_term_registration, submission: s)
      s
    end

    let(:group_member_solitary_submission) do
      s = FactoryGirl.create(:submission, exercise: solitary_exercise)
      s.submission_assets = FactoryGirl.create_list(:submission_asset, 5, submission: s)
      FactoryGirl.create(:exercise_registration, exercise: solitary_exercise, term_registration: group_member_term_registration, submission: s)
      s
    end

    let!(:solitary_submission_of_other_student) do
      s = FactoryGirl.create(:submission, exercise: solitary_exercise)
      s.submission_assets = FactoryGirl.create_list(:submission_asset, 3, submission: s)
      FactoryGirl.create(:exercise_registration, exercise: solitary_exercise, term_registration: other_student_term_registration, submission: s)
      s
    end

    let(:group_submission) do
      s = FactoryGirl.create(:submission, exercise: group_exercise)
      FactoryGirl.create(:exercise_registration,  exercise: group_exercise, term_registration: student_term_registration, submission: s)
      s.submission_assets = FactoryGirl.create_list(:submission_asset, 3, submission: s)
      FactoryGirl.create(:exercise_registration,  exercise: group_exercise, term_registration: group_member_term_registration, submission: s)
      s
    end

    let(:result_publication_of_tutorial_group) { solitary_exercise.result_publications.where(tutorial_group: tutorial_group).first }
    let(:result_publication_of_other_tutorial_group) { solitary_exercise.result_publications.where(tutorial_group: other_tutorial_group).first }

    let(:group_member_account) do
      FactoryGirl.create(:account)
    end

    let!(:rating_events) do
      e = []
      e << event_service.rating_created!(rating)
      e << event_service.rating_updated!(rating)
      e << event_service.rating_destroyed!(rating)
      e
    end

    let!(:rating_group_events) do
      e = []
      e << event_service.rating_group_created!(rating_group)
      e << event_service.rating_group_updated!(rating_group)
      e << event_service.rating_group_destroyed!(rating_group)
      e
    end

    let!(:student_submission_events) do
      e = []
      e << event_service.submission_created!(student_solitary_submission)
      e << event_service.submission_extracted!(student_solitary_submission, student_solitary_submission.submission_assets.first, student_solitary_submission.submission_assets.last(2))
      e << event_service.submission_assets_destroyed!(student_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_extracted!(student_solitary_submission.submission_assets.first, student_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_uploaded!(student_solitary_submission.submission_assets.last)
      e << event_service.submission_asset_extraction_failed!(student_solitary_submission.submission_assets.first, student_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_destroyed!(student_solitary_submission.submission_assets.first)
      e
    end

    let!(:group_member_solitary_submission_events) do
      e = []
      e << event_service.submission_created!(group_member_solitary_submission)
      e << event_service.submission_extracted!(group_member_solitary_submission, group_member_solitary_submission.submission_assets.first, group_member_solitary_submission.submission_assets.last(2))
      e << event_service.submission_assets_destroyed!(group_member_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_extracted!(group_member_solitary_submission.submission_assets.first, student_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_uploaded!(group_member_solitary_submission.submission_assets.last)
      e << event_service.submission_asset_extraction_failed!(group_member_solitary_submission.submission_assets.first, group_member_solitary_submission.submission_assets.last(2))
      e << event_service.submission_asset_destroyed!(group_member_solitary_submission.submission_assets.first(2).last)

      e
    end

    let!(:submission_events_of_group_exercise) do
      es = EventService.new(group_member_account, term)

      e = []
      e << event_service.submission_created!(group_submission)
      e << event_service.submission_extracted!(group_submission, group_submission.submission_assets.first, group_submission.submission_assets.last(2))
      e << event_service.submission_assets_destroyed!(group_submission.submission_assets.last(2))
      e << event_service.submission_asset_extracted!(group_submission.submission_assets.first, group_submission.submission_assets.last(2))
      e << event_service.submission_asset_uploaded!(group_submission.submission_assets.last)
      e << event_service.submission_asset_extraction_failed!(group_submission.submission_assets.first, group_submission.submission_assets.last(2))
      e << event_service.submission_asset_destroyed!(group_submission.submission_assets.first)
      e
    end

    let!(:submission_events_of_others) do
      es = EventService.new(other_student_account, term)

      e = []
      e << es.submission_created!(solitary_submission_of_other_student)
      e << event_service.submission_extracted!(solitary_submission_of_other_student, solitary_submission_of_other_student.submission_assets.first, solitary_submission_of_other_student.submission_assets.last(2))
      e << event_service.submission_assets_destroyed!(solitary_submission_of_other_student.submission_assets.last(2))
      e << event_service.submission_asset_extracted!(solitary_submission_of_other_student.submission_assets.first, solitary_submission_of_other_student.submission_assets.last(2))
      e << event_service.submission_asset_uploaded!(solitary_submission_of_other_student.submission_assets.last)
      e << event_service.submission_asset_extraction_failed!(solitary_submission_of_other_student.submission_assets.first, solitary_submission_of_other_student.submission_assets.last(2))
      e << event_service.submission_asset_destroyed!(solitary_submission_of_other_student.submission_assets.first)
      e
    end

    let!(:result_publication_events_of_tutorial_group) do
      e = []
      e << event_service.result_publication_published!(result_publication_of_tutorial_group)
      e << event_service.result_publication_concealed!(result_publication_of_tutorial_group)
      e
    end

    let!(:result_publication_events_of_other_tutorial_group) do
      e = []
      e << event_service.result_publication_published!(result_publication_of_other_tutorial_group)
      e << event_service.result_publication_concealed!(result_publication_of_other_tutorial_group)
      e
    end

    let(:all_events) do
      rating_events + rating_group_events + student_submission_events + submission_events_of_others + group_member_solitary_submission_events + submission_events_of_group_exercise +
      result_publication_events_of_tutorial_group + result_publication_events_of_other_tutorial_group
    end

    subject { EventPolicy::Scope.new(account, Event.all) }

    describe 'as an admin' do
      let(:account) { admin_account }

      it 'is expected that all events are valid' do
        expect(all_events).to all(be_valid)
      end

      it 'returns all events' do
        records = subject.resolve

        expect(records.distinct).to match_array(all_events.uniq)
      end
    end

    describe 'as student' do
      let(:account) { student_account }

      it 'returns only own submission events and group member submission events for group submissions' do
        expect(subject.resolve.distinct).to match_array((student_submission_events + submission_events_of_group_exercise + result_publication_events_of_tutorial_group).uniq)
      end
    end

    describe 'as a tutor' do
      let(:account) { tutor_account }

      it 'returns all events' do
        expect(subject.resolve.distinct).to match_array(all_events.uniq)
      end
    end

    describe 'as a lecturer' do
      let(:account) { lecturer_account }

      it 'returns all events' do
        expect(subject.resolve.distinct).to match_array(all_events.uniq)
      end
    end
  end
end
