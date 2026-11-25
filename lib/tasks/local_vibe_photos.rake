namespace :local_vibe_photos do
  desc "Validate or import local prototype photos (development only)"
  task import: :environment do
    LocalVibePhotoImporter.new(
      write: ENV["WRITE"] == "1",
      activate: ENV["ACTIVATE"] == "1",
      include_reserve: ENV["INCLUDE_RESERVE"] == "1"
    ).call
  end
end
