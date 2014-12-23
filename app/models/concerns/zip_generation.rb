module ZipGeneration
  extend ActiveSupport::Concern

  def generate_zip_and_assign_to_file!(directory)
    zips_path = Rails.root.join("tmp/exports")
    FileUtils.mkdir_p(zips_path)

    zip_filename = File.join(zips_path, "#{term.course.title.parameterize}-#{term.title.parameterize}-#{Time.now.strftime "%Y%m%d-%H%M"}-#{self.id}.zip")
    FileUtils.rm(zip_filename) if File.exist? zip_filename

    # this ensures that there is at least one file to create a zip for
    # otherwise the zip command fails and therefore this export fails
    File.write(File.join(directory, 'export.txt'), "Export created on #{Time.now}")

    cmd = %Q{cd "#{directory}" && zip -r "#{zip_filename}" *}
    `#{cmd}`

    self.file = File.open(zip_filename)
  end
end
