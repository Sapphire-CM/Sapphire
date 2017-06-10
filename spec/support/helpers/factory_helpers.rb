module FactoryHelpers
  def rating_factory(type)
    type = type.class unless type.is_a? Class

    type.name.demodulize.underscore
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
  config.include FactoryHelpers
end
