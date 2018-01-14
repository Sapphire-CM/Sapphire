json.more @subjects.count > 5
json.subjects @subjects.limit(5) do |subject|
  json.id subject.id
  json.html submission_bulk_subject(subject)
end