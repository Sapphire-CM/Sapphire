# after changes in this file you have to run this on the server
# for the crontab file to be updated
#   bundle exec whenever --update-crontab sapphire --set environment=production

every 1.minutes do
  # rake 'sapphire:auto_responder RESPONDER=web_research'
  rake 'sapphire:auto_responder[19,web_research]'
  rake 'sapphire:auto_responder[26,web_research]'
end
