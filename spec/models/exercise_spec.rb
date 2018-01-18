require 'rails_helper'

describe Exercise do
  let!(:term) { FactoryGirl.create :term }
  let!(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }
  subject { FactoryGirl.create :exercise, term: term }

  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:deadline).of_type(:datetime) }
    it { is_expected.to have_db_column(:late_deadline).of_type(:datetime) }
    it { is_expected.to have_db_column(:row_order).of_type(:integer) }
    it { is_expected.to have_db_column(:group_submission).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:submission_viewer_identifier).of_type(:string) }
    it { is_expected.to have_db_column(:enable_max_total_points).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:max_total_points).of_type(:integer) }
    it { is_expected.to have_db_column(:enable_min_required_points).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:min_required_points).of_type(:integer) }
    it { is_expected.to have_db_column(:enable_max_upload_size).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:maximum_upload_size).of_type(:integer) }
    it { is_expected.to have_db_column(:enable_student_uploads).of_type(:boolean).with_options(default: true,  null: false) }
    it { is_expected.to have_db_column(:visible_points).of_type(:integer) }
    it { is_expected.to have_db_column(:instructions_url).of_type(:string) }
    it { is_expected.to have_db_column(:enable_bulk_submission_management).of_type(:boolean).with_options(default: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:term) }
    it { is_expected.to have_many(:result_publications).dependent(:destroy) }
    it { is_expected.to have_many(:submissions) }
    it { is_expected.to have_many(:services).dependent(:destroy) }
    it { is_expected.to have_many(:rating_groups).dependent(:destroy) }

    it { is_expected.to have_many(:submission_evaluations).through(:submissions) }
    it { is_expected.to have_many(:ratings).through(:rating_groups) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:term) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:term_id) }

    pending "presence of min_required_points"
    pending "presence of max_total_points"
    pending "presence of maximum_upload_size"
    pending "presence of deadline"

    context 'validates deadlines properly' do
      it 'is not valid if deadline is missing and late_deadline is present' do
        subject.deadline = nil
        subject.late_deadline = Time.now
        expect(subject).not_to be_valid
      end

      it 'is valid if late_deadline is after deadline' do
        subject.deadline = Time.now
        subject.late_deadline = Time.now + 1.day
        expect(subject).to be_valid
      end

      it 'is not valid if late_deadline is before deadline' do
        subject.deadline = Time.now + 1.day
        subject.late_deadline = Time.now
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'creation' do
    it 'ensures result publications on create' do
      expect(subject.result_publications.count).to eq(4)
    end

    it 'destroys result publications on delete' do
      subject # trigger creation
      expect do
        subject.destroy
      end.to change { ResultPublication.count }.by(-4)
    end
  end

  describe 'methods' do
    describe '#result_publication_for' do
      it 'is able to fetch result publication for a given tutorial group' do
        result_publication = subject.result_publication_for(tutorial_groups[1])

        expect(result_publication).to be_present
        expect(result_publication.tutorial_group).to eq(tutorial_groups[1])
      end
    end

    describe '#result_published_for?' do
      it 'is able to determine result publication status for a given tutorial group' do
        expect(subject.result_published_for? tutorial_groups[1]).to eq(false)
      end
    end


    describe '#starting_points_sum' do
      let!(:rating_groups) {FactoryGirl.create_list(:rating_group, 3, points: 7, exercise: subject) }

      it 'returns the sum of rating group points' do
        expect(subject.starting_points_sum).to eq(21)
      end
    end
  end
end
