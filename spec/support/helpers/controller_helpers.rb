module ControllerHelpers
  def sign_in(account = FactoryGirl.create(:account))
    if account.nil?
      allow(request.env['warden']).to receive(:authenticate!)
        .and_throw(:warden, scope: :account)

      allow(controller).to receive(:current_account)
        .and_return(nil)
    else
      allow(request.env['warden']).to receive(:authenticate!)
        .and_return(account)

      allow(controller).to receive(:current_account)
        .and_return(account)
    end
  end

  def prepare_rack_uploaded_test_file(file, content_type: "text/plain", rename_to: nil)
    src_file = File.join(Rails.root, 'spec', 'support', 'data', file)

    file_path = if rename_to.present?
      dst_file = File.join(Rails.root, 'tmp', rename_to.presence || file)
      FileUtils.cp src_file, dst_file
      dst_file
    else
      src_file
    end

    Rack::Test::UploadedFile.new(file_path, content_type)
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
end
