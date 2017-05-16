RSpec.shared_examples "basic submission tree operations" do
  describe 'traversing the tree' do
    let!(:submission_assets) do
      assets = []
      assets << top_level_asset
      assets << FactoryGirl.create(:submission_asset, submission: submission, path: "sub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-2.txt"))
      assets << FactoryGirl.create(:submission_asset, submission: submission, path: "sub-folder/subsub-folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "text-3.txt"))
      assets
    end

    let(:top_level_asset) { FactoryGirl.create(:submission_asset, submission: submission, path:"", file: prepare_static_test_file("simple_submission.txt", rename_to: "tl-text-1.txt")) }


    scenario 'sees top-level files' do
      visit tree_submission_path(submission)

      expect(page).to have_link("tl-text-1.txt")
    end

    scenario 'can open a submission asset' do
      visit tree_submission_path(submission)

      click_link "tl-text-1.txt"

      expect(page.current_path).to eq(submission_asset_path(top_level_asset))
    end

    scenario 'can open subfolders' do
      visit tree_submission_path(submission)

      expect(page.current_path).to eq(tree_submission_path(submission))

      click_link "sub-folder"

      expect(page.current_path).to eq(tree_submission_path(submission, path: "sub-folder"))
      expect(page).to have_link("text-2.txt")
    end

    scenario 'can navigate up the tree by using the tree path view' do
      visit tree_submission_path(submission, path: "sub-folder/subsub-folder")

      within '.tree-path' do
        click_link "sub-folder"
      end

      expect(page.current_path).to eq(tree_submission_path(submission, path: "sub-folder"))

      within '.tree-path' do
        click_link "submission"
      end

      expect(page.current_path).to eq(tree_submission_path(submission, path: ""))
    end

    scenario 'can navigate up the tree by using the ".." link' do
      visit tree_submission_path(submission, path: "sub-folder/subsub-folder")

      within '.submission-tree' do
        click_link ".."
      end

      expect(page.current_path).to eq(tree_submission_path(submission, path: "sub-folder"))

      within '.submission-tree' do
        click_link ".."
      end

      expect(page.current_path).to eq(tree_submission_path(submission, path: ""))
    end
  end

  describe 'uploading' do
    context 'without JS' do
      scenario 'a new file' do
        visit tree_submission_path(submission)

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        fill_in 'Path', with: 'new/submission/path'
        attach_file 'File', 'spec/support/data/simple_submission.txt'

        click_button 'Save'

        visit tree_submission_path(submission, path: "new/submission/path")
        expect(page).to have_content("simple_submission.txt")
      end

      scenario 'a zip file'do
        visit tree_submission_path(submission)

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        fill_in 'Path', with: 'zip-subfolder'
        attach_file 'File', 'spec/support/data/submission.zip'

        click_button 'Save'

        visit tree_submission_path(submission, path: "zip-subfolder")

        expect(page).to have_link("simple_submission.txt")
        expect(page).to have_link("some_xa__x_xu__x_xo__x_x__x_nasty_file.txt")
      end
    end

    context 'with JS' do
      scenario 'a new file without setting another path', js: true do
        visit tree_submission_path(submission, path: "non-existent-folder")

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        drop_in_dropzone ['spec/support/data/simple_submission.txt'], '.dropzone-placeholder'

        # wait for the upload to finish
        page.find('.preview-container .status-success')

        visit tree_submission_path(submission, path: "non-existent-folder")

        expect(page).to have_link("simple_submission.txt")
      end

      scenario 'a new file and setting another path', js: true do
        visit tree_submission_path(submission, path: "non-existent-folder")

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        sleep 1 # neccessary to make this spec more robust - otherwise the edit link does not behave as intended

        within '.reveal-modal.open' do
          click_link 'edit'

          fill_in 'submission_upload_path', with: "another/test/path"
        end


        drop_in_dropzone ['spec/support/data/simple_submission.txt'], '.dropzone-placeholder'
        # wait for the upload to finish
        find('.preview-container .status-success')

        visit tree_submission_path(submission, path: "another/test/path")
        expect(page).to have_link("simple_submission.txt")
      end

      scenario 'a new zip file', js: true do
        visit tree_submission_path(submission, path: "non-existent-folder")

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        drop_in_dropzone ['spec/support/data/submission.zip'], '.dropzone-placeholder'
        # wait for the upload to finish
        find('.preview-container .status-success')

        visit tree_submission_path(submission, path: "non-existent-folder")

        expect(page).to have_link("simple_submission.txt")
        expect(page).to have_link("some_xa__x_xu__x_xo__x_x__x_nasty_file.txt")
      end


      scenario 'an existing file', js: true do
        visit tree_submission_path(submission, path: "")

        within '.submission-tree-toolbar' do
          click_link "Upload"
        end

        drop_in_dropzone ['spec/support/data/simple_submission.txt'], '.dropzone-placeholder'
        # wait for the upload to finish
        find('.preview-container .status-success')

        drop_in_dropzone ['spec/support/data/simple_submission.txt'], '.dropzone-placeholder'

        # wait for the second upload to finish

        expect(page.find('.preview-container .status-error')).to be_truthy
        expect(page).to have_content("File already exists")
      end
    end
  end

  describe 'creating folders' do
    context 'without JS' do
      scenario 'redirects to the appropriate path' do
        visit tree_submission_path(submission)

        within '.submission-tree-toolbar' do
          click_link "Folder"
        end

        fill_in 'submission_folder_name', with: "test/path"
        click_button "Create"

        expect(page.current_path).to eq(tree_submission_path(submission, path: "test/path"))
      end
    end

    context 'with JS' do
      scenario 'redirects to the appropriate path', js: true do
        visit tree_submission_path(submission)

        within '.submission-tree-toolbar' do
          click_link "Folder"
        end

        fill_in 'submission_folder_name', with: "test/path"

        expect(page).to have_content("Folder name available")

        click_button "Create"

        expect(page.current_path).to eq(tree_submission_path(submission, path: "test/path"))
      end
    end
  end

  describe 'removing' do
    let!(:submission_assets) do
      assets = []
      assets << FactoryGirl.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt"))
      assets << FactoryGirl.create(:submission_asset, submission: submission, path: "folder", file: prepare_static_test_file("simple_submission.txt"))
      assets << FactoryGirl.create(:submission_asset, submission: submission, path: "folder", file: prepare_static_test_file("simple_submission.txt", rename_to: "simple_submission_2.txt"))
      assets
    end

    scenario 'files', js: true do
      visit tree_submission_path(submission)

      within '.submission-tree table tr:nth-child(2)' do
        expect(page).to have_content("simple_submission.txt")
        find("a[data-method=delete]").click
      end

      visit tree_submission_path(submission)

      expect(page).to have_no_content("simple_submission.txt")
    end

    scenario 'folders', js: true do
      visit tree_submission_path(submission)

      within '.submission-tree table tr:nth-child(1)' do
        expect(page).to have_content("folder")
        find("a[data-method=delete]").click
      end

      visit tree_submission_path(submission)

      expect(page).to have_no_content("folder")
    end
  end
end