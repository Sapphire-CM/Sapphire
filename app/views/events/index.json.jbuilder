json.events_html render(partial: 'events_list', locals: {events: @events}, formats: [:html])
json.includes_entries !@events.empty?
