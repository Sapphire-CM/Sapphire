class SapphireUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    Rails.root.join "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    Rails.root.join 'uploads/tmp'
  end

  def move_to_cache
    true
  end

  def move_to_store
    true
  end
end
