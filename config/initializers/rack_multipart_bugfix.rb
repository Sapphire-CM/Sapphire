# https://github.com/djcp/milk_steak/commit/d01af3a16b164f81cf958a438b82451459474952
# Bump up multipart limit to work around rack/rack#814

# this fixes:
# Exception Rack::Multipart::MultipartPartLimitError in Rack application object
# (Too many open files - Maximum file multiparts in content reached)

Rack::Utils.multipart_part_limit = (ENV['MULTIPART_PART_LIMIT'] || 2048).to_i
