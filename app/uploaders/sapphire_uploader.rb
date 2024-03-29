class SapphireUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    Rails.root.join "uploads", model.class.to_s.underscore, mounted_as.to_s, model.id.to_s
  end

  def cache_dir
    Rails.root.join "uploads", "tmp"
  end

  def move_to_cache
    !Sapphire.running_on_windows?
  end

  def move_to_store
    !Sapphire.running_on_windows?
  end

end
