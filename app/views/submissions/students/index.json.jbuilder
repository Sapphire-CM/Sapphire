json.more @term_registrations.count > 5
json.subjects @term_registrations do |term_registration|
  json.id term_registration.id
  json.html submission_term_registration(term_registration)
end