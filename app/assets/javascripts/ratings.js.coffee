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
  multiplication_factor_field = fields.find 'div[class*="rating_multiplication_factor"]'


  value_label = value_field.find 'label'
  min_label = min_field.find 'label'
  max_label = max_field.find 'label'
  multiplication_factor_label = multiplication_factor_field.find 'label'

  switch type
    when "Ratings::FixedPointsDeductionRating"
      value_field.show()
      min_field.hide()
      max_field.hide()
      multiplication_factor_field.hide()
      value_label.text "Points (negative)"
    when "Ratings::FixedBonusPointsRating"
      value_field.show()
      min_field.hide()
      max_field.hide()
      multiplication_factor_field.hide()
      value_label.text "Points (positive)"
    when "Ratings::FixedPercentageDeductionRating"
      value_field.show()
      min_field.hide()
      max_field.hide()
      multiplication_factor_field.hide()
      value_label.text "Percentage (0...100)"
    when "Ratings::VariablePointsDeductionRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      multiplication_factor_field.hide()
      min_label.text "Minimum Value (points)"
      max_label.text "Maximum Value (points)"
    when "Ratings::VariableBonusPointsRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      multiplication_factor_field.hide()
      min_label.text "Minimum Value (points)"
      max_label.text "Maximum Value (points)"
    when "Ratings::VariablePercentageDeductionRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      multiplication_factor_field.hide()
      min_label.text "Minimum Percent"
      max_label.text "Maximum Percent"
    when "Ratings::PlagiarismRating"
      value_field.hide()
      min_field.hide()
      max_field.hide()
      multiplication_factor_field.hide()
    when "Ratings::PerItemPointsDeductionRating"
      value_field.hide()
      min_field.show()
      max_field.show()
      min_label.text "# items minimum"
      max_label.text "# items maximum"
      multiplication_factor_field.show()
    else
      console.warn("Unknown rating type", type)
