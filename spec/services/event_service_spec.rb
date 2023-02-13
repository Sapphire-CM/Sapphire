require 'rails_helper'

RSpec.describe EventService do
  let(:account) { FactoryBot.create(:account) }
  let(:term) { FactoryBot.create(:term) }

  subject { EventService.new(account, term) }

  describe 'initialization' do
    it 'accepts an account and a term as arguments' do
      expect do
        EventService.new(account, term)
      end.not_to raise_error
    end

    it 'raises an error, when no account is passed' do
      expect do
        EventService.new(nil, term)
      end.to raise_error(ArgumentError)
    end

    it 'raises an error, when no term is passed' do
      expect do
        EventService.new(account, nil)
      end.to raise_error(ArgumentError)
    end

    it 'raises an error, when an instance of a class other than Account is passed as first argument ' do
      expect do
        EventService.new(term, term)
      end.to raise_error(ArgumentError)
    end

    it 'raises an error, when an instance of a class other than Term is passed as second argument' do
      expect do
        EventService.new(account, account)
      end.to raise_error(ArgumentError)
    end
  end

  describe 'attributes' do
    it 'provides a reader for account' do
      expect(subject.account).to eq(account)
    end

    it 'provides a reader for term' do
      expect(subject.term).to eq(term)
    end
  end

  context 'submission events' do
    let(:term_registration) { FactoryBot.create(:term_registration, :student) }
    let(:account) { term_registration.account }
    let(:term) { term_registration.term }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:submission) { FactoryBot.create(:submission, exercise: exercise, submitter: account) }

    describe '#submission_created!' do
      it 'creates a Events::Submission::Created event' do
        expect do
          expect(subject.submission_created!(submission)).to be_a Events::Submission::Created
        end.to change(Events::Submission::Created, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.submission_created!(submission)

        expect(event.submission_id).to eq(submission.id)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
      end
    end

    describe '#submission_extracted!' do
      let(:zip_submission_asset) { FactoryBot.create(:submission_asset, submission: submission, path: 'zip/path', file: prepare_static_test_file('submission.zip')) }
      let(:extracted_submission_assets) do
        [
          FactoryBot.create(:submission_asset, :plain_text, submission: submission, path: 'one'),
          FactoryBot.create(:submission_asset, :plain_text, submission: submission, path: 'two'),
          FactoryBot.create(:submission_asset, :plain_text, submission: submission, path: 'three')
        ]
      end

      it 'creates a Events::Submission::Extracted event' do
        expect do
          expect(subject.submission_extracted!(submission, zip_submission_asset, extracted_submission_assets)).to be_a Events::Submission::Extracted
        end.to change(Events::Submission::Extracted, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.submission_extracted!(submission, zip_submission_asset, extracted_submission_assets)

        expect(event.submission_id).to eq(submission.id)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.zip_file).to eq('submission.zip')
        expect(event.zip_path).to eq('zip/path')
        expect(event.extracted_submission_assets).to match(extracted_submission_assets.map { |sa|
          {
            file: File.basename(sa.file.to_s),
            path: sa.path,
            content_type: SubmissionAsset::Mime::PLAIN_TEXT
          }
        })
      end
    end
  end

  describe '#submission_folder_renamed!' do
    let(:term_registration) { FactoryBot.create(:term_registration, :student) }
    let(:account) { term_registration.account }
    let(:term) { term_registration.term }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:submission) { FactoryBot.create(:submission, exercise: exercise, submitter: account) }
    let(:directory) { submission.tree.resolve("directory") }
    let(:submission_folder_rename) { FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory) }

    it 'creates a new Events::Submission::Updated event if no previous event exists' do
      expect do
        expect(subject.submission_folder_renamed!(submission_folder_rename)).to be_a Events::Submission::Updated
      end.to change(Events::Submission::Updated, :count).by(1)
    end

    it 'updates the existing Events::Submission::Updated event if it already exists' do
      existing_event = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: Time.now - 15.minutes)

      expect do
        expect(subject.submission_folder_renamed!(submission_folder_rename)).to eq(existing_event)
      end.not_to change(Events::Submission::Updated, :count)
    end

    it 'correctly sets up and returns the event' do
      event = subject.submission_folder_renamed!(submission_folder_rename)

      expect(event.submission_id).to eq(submission.id)
      expect(event.exercise_id).to eq(submission.exercise.id)
      expect(event.exercise_title).to eq(submission.exercise.title)

      updated_assets = event.submission_assets[:updated]
      expect(updated_assets.length).to eq(1)

      updated_asset = updated_assets.first
      expect(updated_asset[:file]).to eq([submission_folder_rename.path_old, submission_folder_rename.path_new])
      expect(updated_asset[:path]).to eq([])
      expect(updated_asset[:content_type]).to eq([])
    end
  end


  context 'submission asset events' do
    let(:exercise) { submission.exercise }
    let(:term) { exercise.term }
    let(:submission) { FactoryBot.create(:submission) }
    let(:submission_assets) { FactoryBot.create_list(:submission_asset, 3, :plain_text, submission: submission) }
    let(:zip_asset) { FactoryBot.create(:submission_asset, :zip, submission: submission) }

    describe '#submission_asset_renamed!' do
      let(:rename) { FactoryBot.create(:submission_asset_rename) }
      let(:submission_asset) { rename.submission_asset }
      let(:submission) { rename.submission }

      it 'creates a new Events::Submission::Updated event if no previous event exists' do
        expect do
          expect(subject.submission_asset_renamed!(rename)).to be_a Events::Submission::Updated
        end.to change(Events::Submission::Updated, :count).by(1)
      end

      it 'updates the existing Events::Submission::Updated event if it already exists' do
        existing_event = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: Time.now - 15.minutes)

        expect do
          expect(subject.submission_asset_renamed!(rename)).to eq(existing_event)
        end.not_to change(Events::Submission::Updated, :count)
      end

      it 'correctly sets up and returns the event' do
        event = subject.submission_asset_renamed!(rename)

        expect(event.submission_id).to eq(submission.id)
        expect(event.exercise_id).to eq(submission.exercise.id)
        expect(event.exercise_title).to eq(submission.exercise.title)

        updated_assets = event.submission_assets[:updated]
        expect(updated_assets.length).to eq(1)

        updated_asset = updated_assets.first
        expect(updated_asset[:file]).to eq([File.basename(rename.filename_old), File.basename(rename.new_filename)])
        expect(updated_asset[:path]).to eq(submission_asset.path)
        expect(updated_asset[:content_type]).to eq(submission_asset.content_type)
      end
    end

    describe '#submission_asset_destroyed!' do
      let(:now) { Time.now }

      it 'creates a new Events::Submission::Updated if the last one is older than 30 minutes' do
        Timecop.freeze(now)
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now - 31.minutes)

        expect(subject.submission_asset_destroyed!(zip_asset)).not_to eq(old_submission_asset)
        Timecop.return
      end
      it 'updates the last new Events::Submission::Updated if the last one was created less than 30 minutes ago' do
        Timecop.freeze(now)
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now - 29.minutes)

        expect(subject.submission_asset_destroyed!(zip_asset)).to eq(old_submission_asset)
        Timecop.return
      end

      it 'updates the last new Events::Submission::Updated if there were events from other students in the meantime' do
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now)
        other_submission_asset = Events::Submission::Updated.create(subject: submission, term: term, updated_at: now - 29.minutes)

        expect(subject.submission_asset_destroyed!(zip_asset)).to eq(old_submission_asset)
      end
    end

    describe '#submission_asset_uploaded!' do
      let(:now) { Time.now }

      it 'creates a new Events::Submission::Updated if the last one is older than 30 minutes' do
        Timecop.freeze(now)
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now - 31.minutes)

        expect(subject.submission_asset_uploaded!(zip_asset)).not_to eq(old_submission_asset)
        Timecop.return
      end
      it 'updates the last new Events::Submission::Updated if the last one was created less than 30 minutes ago' do
        Timecop.freeze(now)
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now - 29.minutes)

        expect(subject.submission_asset_uploaded!(zip_asset)).to eq(old_submission_asset)
        Timecop.return
      end

      it 'updates the last new Events::Submission::Updated if there were events from other students in the meantime' do
        old_submission_asset = Events::Submission::Updated.create(account: account, subject: submission, term: term, updated_at: now)
        other_submission_asset = Events::Submission::Updated.create(subject: submission, term: term, updated_at: now - 29.minutes)

        expect(subject.submission_asset_uploaded!(zip_asset)).to eq(old_submission_asset)
      end
    end

    describe '#submission_asset_extracted!' do
      it 'calls #submission_asset_uploaded! with each given submission_asset' do
        expect(subject).to receive(:submission_asset_uploaded!).exactly(submission_assets.length).times.and_call_original
        expect(subject.submission_asset_extracted!(zip_asset, submission_assets)).to be_a(Events::Submission::Updated)
      end
    end

    describe '#submission_assets_destroyed!' do
      it 'calls #submission_asset_destroyed! with each given submission_asset' do
        expect(subject).to receive(:submission_asset_destroyed!).exactly(submission_assets.length).times.and_call_original
        expect(subject.submission_assets_destroyed!(submission_assets)).to be_a(Events::Submission::Updated)
      end
    end
  end

  context 'rating events' do
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
    let(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group, title: 'my rating', value: -2, description: 'nice!') }

    describe '#rating_created!' do
      it 'creates a Events::Rating::Created event' do
        expect do
          expect(subject.rating_created!(rating)).to be_a Events::Rating::Created
        end.to change(Events::Rating::Created, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.rating_created!(rating)

        expect(event.subject).to eq(rating)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.rating_title).to eq(rating.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.value).to eq(rating.value)
      end
    end

    describe '#rating_updated!' do
      it 'creates a Events::Rating::Updated event' do
        expect do
          expect(subject.rating_updated!(rating)).to be_a Events::Rating::Updated
        end.to change(Events::Rating::Updated, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        rating.assign_attributes(title: 'your rating', value: -42, description: nil)

        event = subject.rating_updated!(rating)

        expect(event.subject).to eq(rating)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.rating_title).to eq(rating.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.value).to eq(rating.value)
        expect(event.tracked_changes).to match('title' => ['my rating', 'your rating'],
          'value' => [-2, -42],
          'description' => ['nice!', nil])
      end
    end

    describe '#rating_destroyed!' do
      it 'creates a Events::Rating::Destroyed event' do
        expect do
          expect(subject.rating_destroyed!(rating)).to be_a Events::Rating::Destroyed
        end.to change(Events::Rating::Destroyed, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.rating_destroyed!(rating)

        expect(event.subject).to eq(rating)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.rating_title).to eq(rating.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.value).to eq(rating.value)
      end
    end
  end

  context 'rating group events' do
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise, title: 'nice title', points: 5) }

    describe '#rating_group_created!' do
      it 'creates a Events::RatingGroup::Created event' do
        expect do
          expect(subject.rating_group_created!(rating_group)).to be_a Events::RatingGroup::Created
        end.to change(Events::RatingGroup::Created, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.rating_group_created!(rating_group)

        expect(event.subject).to eq(rating_group)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.points).to eq(rating_group.points)
      end
    end

    describe '#rating_group_updated!' do
      it 'creates a Events::RatingGroup::Updated event' do
        expect do
          expect(subject.rating_group_updated!(rating_group)).to be_a Events::RatingGroup::Updated
        end.to change(Events::RatingGroup::Updated, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        rating_group.assign_attributes(title: 'new title', points: 42)

        event = subject.rating_group_updated!(rating_group)

        expect(event.subject).to eq(rating_group)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.points).to eq(rating_group.points)
        expect(event.tracked_changes).to match('title' => ['nice title', 'new title'],
          'points' => [5, 42])
      end
    end

    describe '#rating_group_destroyed!' do
      it 'creates a Events::RatingGroup::Destroyed event' do
        expect do
          expect(subject.rating_group_destroyed!(rating_group)).to be_a Events::RatingGroup::Destroyed
        end.to change(Events::RatingGroup::Destroyed, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.rating_group_destroyed!(rating_group)

        expect(event.subject).to eq(rating_group)
        expect(event.rating_group_id).to eq(rating_group.id)
        expect(event.rating_group_title).to eq(rating_group.title)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.points).to eq(rating_group.points)
      end
    end
  end

  context 'result publication events' do
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:result_publication) { ResultPublication.find_by(exercise: exercise, tutorial_group: tutorial_group) }

    describe '#result_publication_published!' do
      it 'creates a Events::ResultPublication::Published event' do
        expect do
          expect(subject.result_publication_published!(result_publication)).to be_a Events::ResultPublication::Published
        end.to change(Events::ResultPublication::Published, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.result_publication_published!(result_publication)

        expect(event.subject).to eq(result_publication)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.tutorial_group_id).to eq(tutorial_group.id)
        expect(event.tutorial_group_title).to eq(tutorial_group.title)
      end
    end

    describe '#result_publication_concealed!' do
      it 'creates a Events::ResultPublication::Concealed event' do
        expect do
          expect(subject.result_publication_concealed!(result_publication)).to be_a Events::ResultPublication::Concealed
        end.to change(Events::ResultPublication::Concealed, :count).by(1)
      end

      it 'correctly sets up and returns the event' do
        event = subject.result_publication_concealed!(result_publication)

        expect(event.subject).to eq(result_publication)
        expect(event.exercise_id).to eq(exercise.id)
        expect(event.exercise_title).to eq(exercise.title)
        expect(event.tutorial_group_id).to eq(tutorial_group.id)
        expect(event.tutorial_group_title).to eq(tutorial_group.title)
      end
    end
  end
end
