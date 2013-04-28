window.pluralize = (value, singular, plural) ->
  title = if Math.abs(value) == 1
    "point"
  else
    "points"
    
  "#{value} #{title}"