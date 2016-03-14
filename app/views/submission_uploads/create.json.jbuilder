if @submission_upload.valid?
  json.status :ok
else
  json.status :invalid
end
