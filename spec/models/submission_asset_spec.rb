require 'rails_helper'

RSpec.describe SubmissionAsset do
  it { is_expected.to belong_to(:submission) }

  it { is_expected.to validate_presence_of(:submission) }
  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to define_enum_for(:extraction_status).with([:extraction_pending, :extraction_in_progress, :extraction_done, :extraction_failed])}

  describe 'validations' do
    let(:submission) { FactoryGirl.create(:submission) }
    subject { FactoryGirl.build(:submission_asset, submission: submission) }

    describe 'upload size' do
      pending
    end

    describe 'path uniqueness' do
      it 'validates the uniqueness of a simple path and file combination' do
        expect(subject).to be_valid

        FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt"))

        subject.path = ""
        subject.file = prepare_static_test_file("simple_submission.txt")

        expect(subject).not_to be_valid
      end

      it 'validates the uniqueness of a non-normalized path and file combination' do
        expect(subject).to be_valid

        FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt"))

        subject.path = "test/.."
        subject.file = prepare_static_test_file("simple_submission.txt")

        expect(subject).not_to be_valid
      end

      it 'detects collision if path is resolves to an existing submission asset with a path at some point' do
        expect(subject).to be_valid

        sa = FactoryGirl.create(:submission_asset, submission: submission, path: "test/folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "path"))

        subject.path = "test/folder/path"
        subject.file = prepare_static_test_file("simple_submission.txt", rename_to: "folder")

        expect(subject).not_to be_valid
      end

      it 'detects collision if path is resolves to an existing submission asset without a path' do
        expect(subject).to be_valid

        sa = FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "path"))

        subject.path = "//path/"
        subject.file = prepare_static_test_file("simple_submission.txt", rename_to: "folder")

        expect(subject).not_to be_valid
      end

      it 'detects collision if path resolves to a path of an existing submission asset' do
        expect(subject).to be_valid

        sa = FactoryGirl.create(:submission_asset, submission: submission, path: "test/folder", file: prepare_static_test_file("simple_submission.txt"))

        subject.path = "test"
        subject.file = prepare_static_test_file("simple_submission.txt", rename_to: "folder")

        expect(subject).not_to be_valid
      end

      it 'detects collision if path resolves to a sub_path of an existing submission asset' do
        expect(subject).to be_valid

        sa = FactoryGirl.create(:submission_asset, submission: submission, path: "test/folder/that/is/fancy", file: prepare_static_test_file("simple_submission.txt"))

        subject.path = "test"
        subject.file = prepare_static_test_file("simple_submission.txt", rename_to: "folder")

        expect(subject).not_to be_valid
      end
    end
  end

  describe "::Mime" do
    it 'provides constants' do
      expect(SubmissionAsset::Mime::NEWSGROUP_POST).to eq('text/newsgroup')
      expect(SubmissionAsset::Mime::EMAIL).to eq('text/email')
      expect(SubmissionAsset::Mime::STYLESHEET).to eq('text/css')
      expect(SubmissionAsset::Mime::HTML).to eq('text/html')
      expect(SubmissionAsset::Mime::JPEG).to eq('image/jpeg')
      expect(SubmissionAsset::Mime::PNG).to eq('image/png')
      expect(SubmissionAsset::Mime::ZIP).to eq('application/zip')
      expect(SubmissionAsset::Mime::PLAIN_TEXT).to eq('text/plain')
      expect(SubmissionAsset::Mime::FAVICON).to eq('image/x-icon')
      expect(SubmissionAsset::Mime::PDF).to eq('application/pdf')
      expect(SubmissionAsset::Mime::IMAGES).to match(['image/jpeg', 'image/png'])
      expect(SubmissionAsset::Mime::ARCHIVES).to match(['application/zip'])
    end
  end

  describe 'scoping' do
    context 'content types' do
      let(:submission) { FactoryGirl.create(:submission) }

      %w(newsgroup_post email stylesheet html jpeg png zip favicon pdf).each do |type|
        let!(type.pluralize.to_sym) do
          sa = FactoryGirl.create(:submission_asset, submission: submission)
          sa.content_type = "SubmissionAsset::Mime::#{type.upcase}".constantize
          sa.save(validate: false)
          [sa]
        end
      end

      let(:images) { jpegs + pngs }
      let(:archives) { zips }

      %w(stylesheets htmls images pdfs archives).each do |type|
        describe ".#{type}" do
          it "only returns #{type.singularize} assets" do
            expect(SubmissionAsset.send(type)).to match(send(type))
          end
        end
      end
    end

    describe '.for_exercise' do
      it 'returns only submission assets for a given exercise' do
        assets = FactoryGirl.create_list(:submission_asset, 3)

        expect(SubmissionAsset.for_exercise(assets.first.submission.exercise)).to eq([assets.first])
      end
    end

    describe '.for_term' do
      it 'returns only submission assets for a given term' do
        assets = FactoryGirl.create_list(:submission_asset, 3)

        expect(SubmissionAsset.for_term(assets.first.submission.exercise.term)).to eq([assets.first])
      end
    end

    describe '.at_path_components' do
      it 'matches with a simple path and file combination' do
        sa = FactoryGirl.create(:submission_asset, path: "", file: prepare_static_test_file("simple_submission.txt"))

        expect(described_class.at_path_components("simple_submission.txt").first).to eq(sa)
      end

      it 'matches non-normalized path and file combination' do
        sa = FactoryGirl.create(:submission_asset, path: "", file: prepare_static_test_file("simple_submission.txt"))

        expect(described_class.at_path_components("test/../simple_submission.txt").first).to eq(sa)
      end

      it 'matches if path is resolves to an existing submission asset with a path at some point' do
        sa = FactoryGirl.create(:submission_asset, path: "test/folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "path"))

        expect(described_class.at_path_components("test/folder/path/folder").first).to eq(sa)
      end

      it 'matches if path is resolves to an existing submission asset without a path' do
        sa = FactoryGirl.create(:submission_asset, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "path"))

        expect(described_class.at_path_components("//path/folder").first).to eq(sa)
      end

      it 'matches if path resolves to a path of an existing submission asset' do
        sa = FactoryGirl.create(:submission_asset, path: "test/folder", file: prepare_static_test_file("simple_submission.txt"))

        expect(described_class.at_path_components("test/folder").first).to eq(sa)

      end

      it 'matches if path resolves to a sub_path of an existing submission asset' do
        sa = FactoryGirl.create(:submission_asset, path: "test/folder/that/is/fancy", file: prepare_static_test_file("simple_submission.txt"))

        expect(described_class.at_path_components("test/folder").first).to eq(sa)
      end

      it 'does not match if path is the same but the file names differ' do
        sa = FactoryGirl.create(:submission_asset, path: "test", file: prepare_static_test_file("simple_submission.txt", rename_to: "file"))

        expect(described_class.at_path_components("test/file2").exists?).to be_falsey
      end

      it 'does not match if path contains only a part of a path' do
        sa = FactoryGirl.create(:submission_asset, path: "test/folder/that/is/fancy", file: prepare_static_test_file("simple_submission.txt"))

        expect(described_class.at_path_components("test/fol").exists?).to be_falsey
      end

    end
  end

  describe 'save callbacks' do
    let(:now) { Time.now }

    subject { FactoryGirl.build(:submission_asset) }

    it 'sets submitted_at' do
      Timecop.freeze(now)
      subject.submitted_at = nil
      subject.file = prepare_static_test_file('simple_submission_2.txt')

      subject.save

      expect(subject.submitted_at).to eq(now)

      Timecop.return
    end

    it 'sets content_type' do
      subject.file = prepare_static_test_file('simple_submission.txt')
      subject.content_type = nil

      subject.save

      expect(subject.content_type).to eq(SubmissionAsset::Mime::PLAIN_TEXT)
    end

    it 'sets the filename' do
      expect(subject.filename).to be_blank
      subject.file = prepare_static_test_file('simple_submission.txt')
      subject.save

      expect(subject.filename).to eq('simple_submission.txt')
    end

    it 'sets file sizes' do
      subject.file = prepare_static_test_file('simple_submission.txt')

      subject.save

      expect(subject.processed_size)
    end

    it 'normalizes path' do
      expect(subject).to receive(:set_normalized_path).and_return(true)

      subject.path = "some/path"
      subject.save
    end
  end

  describe '.path_exists?' do
    it 'calls .at_path_components with given path' do
      expect(described_class).to receive(:at_path_components).with("test/path").and_call_original

      described_class.path_exists?("test/path")
    end
  end

  describe '.inside_path' do
    let!(:assets_outside_path) do
      [
        FactoryGirl.create(:submission_asset, path: "test", file: prepare_static_test_file("simple_submission.txt", rename_to: "file")),
        FactoryGirl.create(:submission_asset, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file"))
      ]
    end

    let!(:assets_inside_path) do
      [
        FactoryGirl.create(:submission_asset, path: "test/folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "folder")),
        FactoryGirl.create(:submission_asset, path: "test/folder/path", file: prepare_static_test_file("simple_submission.txt", rename_to: "folder"))
      ]
    end

    it 'returns all submission assets inside given path' do
      expect(described_class.inside_path("test/folder")).to match_array(assets_inside_path)
    end
  end

  describe '.normalize_path' do
    it 'removes leading and tailing slashes' do
      expect(described_class.normalize_path("/test/path/")).to eq("test/path")
    end

    it 'cleans the path' do
      expect(described_class.normalize_path("test/path/../folder")).to eq("test/folder")
    end

    it 'replaces multiple slashes with a single one' do
      expect(described_class.normalize_path("//test//////path//")).to eq("test/path")
    end

    it 'handles weired paths that resolve to an empty one' do
      expect(described_class.normalize_path("test/..")).to eq("")
    end

    it 'restricts the path to the root level' do
      expect(described_class.normalize_path("asd/../../test")).to eq("test")
    end
  end


  describe '#processed_filesize' do
    it 'returns the filesize of the file' do
      subject.file = prepare_static_test_file('simple_submission.txt')
      subject.set_filesizes

      expect(subject.processed_size).to eq(447)
    end
  end

  describe '#set_submitted_at' do
    let(:now) { Time.now }

    it 'sets submitted_at to current time' do
      Timecop.freeze(now)
      expect(subject.submitted_at).to be_nil
      subject.set_submitted_at

      Timecop.return
      expect(subject.submitted_at).to eq(now)
    end
  end

  describe '#set_content_type' do
    it 'sets the content type according to the file' do
      subject.file = prepare_static_test_file('submission.zip')

      expect(subject.content_type).to be_blank
      subject.set_content_type

      expect(subject.content_type).to eq(SubmissionAsset::Mime::ZIP)
    end
  end

  describe '#utf8_contents' do
    it 'returns the contents of an utf-8 file' do
      subject.file = prepare_static_test_file('simple_submission_2.txt')

      expect(subject.utf8_contents).to eq("äöü UTF 8 encoded submission\n")
    end

    it 'returns the contents of an iso-latin encoded file' do
      subject.file = prepare_static_test_file('submission_asset_iso_latin.txt')

      expect(subject.utf8_contents).to eq("Submission containing special chars encoded with windows-iso latin 1\r\n\r\nÖÄÜßöäü\r\n")
    end

    it 'returns an empty string for an empty file' do
      subject.file = prepare_static_test_file('submission_empty.txt')

      expect(subject.utf8_contents).to eq('')
    end
  end

  describe '#archive?' do
    it "returns true if content_type is 'application/zip'" do
      subject.content_type = "application/zip"

      expect(subject.archive?).to be_truthy
    end

    it "returns false if content_type is not 'application/zip'" do
      subject.content_type = "text/plain"

      expect(subject.archive?).to be_falsey
    end
  end

  describe '#set_filesizes' do
    context 'non archive' do
      it 'sets filesystem_size and processed_size' do
        subject.file = prepare_static_test_file("simple_submission.txt")
        subject.set_filesizes

        expect(subject.filesystem_size).to eq(447)
        expect(subject.processed_size).to eq(447)
      end
    end

    context 'archives' do
      it 'sets filesystem_size and processed_size' do
        subject.file = prepare_static_test_file("submission.zip")
        subject.content_type = SubmissionAsset::Mime::ZIP
        subject.set_filesizes

        expect(subject.filesystem_size).to eq(1059)
        expect(subject.processed_size).to eq(458)
      end
    end
  end

  describe '#set_normalized_path' do
    it 'calls SubmissionAsset.normalize_path with given path' do
      expect(described_class).to receive(:normalize_path).with("//test////path//").and_call_original

      subject.path = "//test////path//"
      subject.set_normalized_path

      expect(subject.path).to eq("test/path")
    end
  end
end
