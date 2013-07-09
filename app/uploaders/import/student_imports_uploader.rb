class Import::StudentImportsUploader < CarrierWave::Uploader::Base

  def store_dir
    Rails.root.join "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    Rails.root.join "uploads/tmp"
  end

end
