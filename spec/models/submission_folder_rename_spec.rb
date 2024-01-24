require 'rails_helper'

RSpec.describe SubmissionFolderRename, type: :model do

  describe 'validates_presence' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }
    let(:directory) { submission.tree.resolve("") }
    subject { FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory) }

    it 'validates presence of submission' do
      expect(subject).to validate_presence_of(:submission)
    end

    it 'validates presence of directory' do
      expect(subject).to validate_presence_of(:directory)
    end

    it 'validates presence of renamed_at' do
      expect(subject).to validate_presence_of(:renamed_at)
    end

    it 'validates presence of path_old' do
      expect(subject).to validate_presence_of(:path_old)
    end

    it 'validates presence of path_new' do
      expect(subject).to validate_presence_of(:path_new)
    end

    it 'validates presence of renamed_by_id' do
      expect(subject).to validate_presence_of(:renamed_by)
    end
  end

  describe 'attributes' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }

    let(:directory) { submission.tree.resolve( "") }
    subject { FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory) }

    it 'has a submission attribute' do
      expect(subject).to respond_to(:submission)
      expect(subject).to respond_to(:submission=)
    end

    it 'has a directory attribute' do
      expect(subject).to respond_to(:directory)
      expect(subject).to respond_to(:directory=)
    end

    it 'has a renamed_at attribute' do
      expect(subject).to respond_to(:renamed_at)
      expect(subject).to respond_to(:renamed_at=)
    end

    it 'has a path_old attribute' do
      expect(subject).to respond_to(:path_old)
      expect(subject).to respond_to(:path_old=)
    end

    it 'has a path_new attribute' do
      expect(subject).to respond_to(:path_new)
      expect(subject).to respond_to(:path_new=)
    end

    it 'has a renamed_by_id attribute' do
      expect(subject).to respond_to(:renamed_by)
      expect(subject).to respond_to(:renamed_by=)
    end
  end

  describe 'delegation' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }

    let(:directory) { submission.tree.resolve( "") }
    subject { FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory) }

    it 'delegates term to submission' do
      expect(subject.term).to eq(submission.term)
    end

    it 'delegates students to submission' do
      expect(subject.students).to eq(submission.students)
    end

    it 'delegates exercise to submission' do
      expect(subject.exercise).to eq(submission.exercise)
    end
  end

  describe 'validations' do
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }

    it 'is valid if renamed directory is not root folder' do
      directory1 = submission.tree.resolve( "directory1")
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1)

      expect(submission_folder_rename.errors[:directory]).to_not include("is the root directory and cannot be renamed")
    end

    it 'is invalid if renamed directory is root folder' do
      root_directory = submission.tree.resolve("")
      submission_folder_rename =  FactoryBot.create(:submission_folder_rename, submission: submission, directory: root_directory)

      expect(submission_folder_rename).to_not be_valid
      expect(submission_folder_rename.errors[:directory]).to include("is the root directory and cannot be renamed")
    end

    it 'is valid if renamed directory is created' do
      directory2 = submission.tree.resolve( "directory1/directory2")
      directory1 = directory2.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1)

      expect(submission_folder_rename.errors[:directory]).to_not include("has no nodes and thus not created and cannot be renamed")
    end

    it 'is invalid if renamed directory is not created' do
      directory1 = submission.tree.resolve( "directory1")
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1)

      expect(submission_folder_rename).to_not be_valid
      expect(submission_folder_rename.errors[:directory]).to include("has no nodes and thus not created and cannot be renamed")
    end

    it 'is valid if new directory name is not the same as the current directory name' do
      directory2 = submission.tree.resolve( "directory1/directory2")
      directory1 = directory2.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1, path_new: "directory2")

      expect(submission_folder_rename.errors[:path_new]).to_not include("has the same value as the previous name of the directory")
    end

    it 'is invalid if new directory name is not the same as the current directory name' do
      directory2 = submission.tree.resolve( "directory1/directory2")
      directory1 = directory2.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1, path_new: "directory1")

      expect(submission_folder_rename).to_not be_valid
      expect(submission_folder_rename.errors[:path_new]).to include("has the same value as the previous name of the directory")
    end

    it 'is valid if new directory name is not taken by another directory on the same level' do
      subdir1 = submission.tree.resolve( "directory1/directory4")
      subdir2 = submission.tree.resolve( "directory2/directory5")
      directory1 = subdir1.parent
      directory2 = subdir2.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1, path_new: "directory3")

      expect(submission_folder_rename).to be_valid
      expect(submission_folder_rename.errors[:path_new]).to_not include("is already taken")
    end

    it 'is invalid if new directory name is taken by another directory on the same level' do
      subdir1 = submission.tree.resolve( "directory1/directory4")
      subdir2 = submission.tree.resolve( "directory2/directory5")
      directory1 = subdir1.parent
      directory2 = subdir2.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1, path_new: "directory2")

      expect(subject).to_not be_valid
      expect(submission_folder_rename.errors[:path_new]).to include("is already taken")
    end

    it 'is valid if new directory name is not taken by another asset on the same level' do
      asset_1 = FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt"))
      directory3 = submission.tree.resolve( "directory1/directory2/directory3")
      directory2 = directory3.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory2, path_new: "directory3")

      expect(submission_folder_rename).to be_valid
      expect(submission_folder_rename.errors[:path_new]).to_not include("is already taken")
    end

    it 'is invalid if new directory name is taken by another asset on the same level' do
      asset_1 = FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt"))
      directory3 = submission.tree.resolve( "directory1/directory2/directory3")
      directory2 = directory3.parent
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory2, path_new: "file1.txt")

      expect(subject).to_not be_valid
      expect(submission_folder_rename.errors[:path_new]).to include("is already taken")
    end
  end

  # I really can not figure out how to mock the @submission.submission_assets here
  # to test the save! method...
  describe "#save!" do

    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term) { term_registration.term }
    let(:term_registration) { current_account.term_registrations.first }
    let(:current_account) { FactoryBot.create(:account, :student) }

    it "renames submission_assets paths and saves successfully" do

      asset_2 = FactoryBot.create(:submission_asset, submission: submission, path: "directory1/directory2", file: prepare_static_test_file("simple_submission.txt", rename_to: "file2.txt"))
      asset_3 = FactoryBot.create(:submission_asset, submission: submission, path: "directory1/directory2/directory3", file: prepare_static_test_file("simple_submission.txt", rename_to: "file3.txt"))
      asset_1 = FactoryBot.create(:submission_asset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt"))
      directory3 = submission.tree.resolve( "directory1/directory2/directory3")
      directory1 = submission.tree.resolve( "directory1")

      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory1, path_new: "directory9")

      assets_relation = instance_double(ActiveRecord::AssociationRelation, where: [])

      submission_assets = [
        instance_double(SubmissionAsset, submission: submission, path: "directory1/directory2", file: prepare_static_test_file("simple_submission.txt", rename_to: "file2.txt")),
        instance_double(SubmissionAsset, submission: submission, path: "directory1/directory2/directory3", file: prepare_static_test_file("simple_submission.txt", rename_to: "file3.txt")),
        instance_double(SubmissionAsset, submission: submission, path: "directory1", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")),
      ]

      allow(submission_folder_rename.submission).to receive(:submission_assets).and_return(assets_relation)
      allow(assets_relation).to receive(:to_a).and_return(submission_assets)

      submission_folder_rename.save!

      submission_assets.each do |asset|
        expect(asset).to receive(:valid?).and_return(true)
        expect(asset).to receive(:save).and_return(true)
      end

      expect(submission_folder_rename.save!).to eq(true)
    end

    it "returns false if validation fails" do
      directory = submission.tree.resolve( "directory")
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory)

      allow(submission_folder_rename).to receive(:valid?).and_return(false)

      expect(submission_folder_rename.save!).to eq(false)
    end

    it "returns false if saving any asset fails" do
      directory = submission.tree.resolve( "directory")
      submission_folder_rename = FactoryBot.create(:submission_folder_rename, submission: submission, directory: directory)

      allow(submission_folder_rename).to receive(:valid?).and_return(true)

      submission_assets = [
        create(:submission_asset, submission: submission, path: "old_path/file1.txt"),
        create(:submission_asset, submission: submission, path: "old_path/subfolder/file2.txt")
      ]

      allow(submission.submission_assets).to receive(:where).and_return(submission_assets)

      submission_assets.each do |asset|
        expect(asset).to receive(:valid?).and_return(true)
        expect(asset).to receive(:save).and_return(false)
      end

      expect(submission_folder_rename.save!).to eq(false)
    end
  end
end
