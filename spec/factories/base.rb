FactoryGirl.define do
  sequence(:lorem_ipsum) { |n| "Lorem ipsum dolor sit amet, consectetur adipisicing elit. #{n}" }
end

def prepare_static_test_file(file, rename_to: nil, open: true)
  src_file = File.join(Rails.root, 'spec', 'support', 'data', file)
  dst_file = File.join(Rails.root, 'tmp', rename_to.presence || file)
  FileUtils.cp src_file, dst_file

  if open
    File.open dst_file
  else
    dst_file
  end
end
