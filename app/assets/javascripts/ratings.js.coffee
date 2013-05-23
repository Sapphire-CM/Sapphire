# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@initRatingForm = ->
  $rating_form = $ '#rating_form'

  if $rating_form.length > 0
    update_fields_visibility($rating_form)

    $rating_form.find(select_selector).change ->
      update_fields_visibility($rating_form)


select_selector = 'select[name*="[type]"]'

update_fields_visibility = (form) ->
  type = form.find(select_selector).val()

  fields = $ '.rating_value_fields'

  value_field = fields.find 'div[class*="rating_value"]'
  min_field = fields.find 'div[class*="rating_min_value"]'
  max_field = fields.find 'div[class*="rating_max_value"]'


  value_label = value_field.find 'label'
  min_label = min_field.find 'label'
  max_label = max_field.find 'label'

  switch type
    when "BinaryNumberRating"
      value_field.show()
      min_field.hide()
      max_field.hide()
      value_label.text "Points (positive or negative)"
    when "BinaryPercentRating"
      value_field.show()
      min_field.hide()
      max_field.hide()
      value_label.text "Percentage (0..100)"
    when "ValueNumberRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      min_label.text "Minimum Points"
      max_label.text "Maximum Points"
    when "ValuePercentRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      min_label.text "Minimum Percent"
      max_label.text "Maximum Percent"
