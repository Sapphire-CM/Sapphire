if @submission_upload.valid?
  json.status :ok
else
  json.status :invalid
  json.errors @submission_upload.errors
end
