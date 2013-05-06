# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.toggle_point_range_fields = (button)->
  $button= $(button)
  $form = $button.closest("form")
  $fields = $form.find('#point_range_fields')
  fields_shown= $fields.is(":visible")
  if fields_shown
    $fields.slideUp()
  else
    $fields.slideDown()
    
  update_button_title(!fields_shown)

update_button_title = (fields_shown)->
  $button = $("#point_range_toggle_button")
  $fields = $('#point_range_fields')
  
  
  $points_input = $('#rating_group_points')
  $min_points_input = $fields.find("#rating_group_min_points")
  $max_points_input = $fields.find("#rating_group_max_points")
  
  if fields_shown == undefined
    fields_shown = $fields.is(':visible')
    
  
  title = ""
  
  unless fields_shown
    title += "Change Pointrange"
    title += " (#{$min_points_input.val()}..#{$max_points_input.val()})"
  else
    title += "Hide Pointranges"
    
  $button.text(title)
  

is_using_default_values = (points_input, min_points_input, max_points_input) ->
  if min_points_input.val() == "" && max_points_input.val() == ""
    using_default_values = true
  else
    if points_input.val() != ""
      points = parseInt points_input.val()
      if points >= 0
        using_default_values = (min_points_input.val() == "0" && max_points_input.val() == "#{points}")
      else
        using_default_values = (min_points_input.val() == "#{points}" && max_points_input.val() == "0")
    else 
      using_default_values = true
      
  if using_default_values
    $('#point_range_fields').find('#rating_group_enable_range_points').val("0")
  else
    $('#point_range_fields').find('#rating_group_enable_range_points').val("1")
  using_default_values 

$ ->
  $form = $('#rating_group_form')
  
  if $form.length > 0
    $fields = $('#point_range_fields')
    
    $points_input = $('#rating_group_points')
    $min_points_input = $fields.find("#rating_group_min_points")
    $max_points_input = $fields.find("#rating_group_max_points")
    
    using_default_values = is_using_default_values($points_input, $min_points_input, $max_points_input)
    
    if using_default_values
      $fields.hide()
      points = parseInt $points_input.val()
      if $points_input.val() == ""
        $min_points_input.val("0")
        $max_points_input.val("0")
      else if points >= 0
        $min_points_input.val("0")
        $max_points_input.val("#{points}")
      else if points < 0
        $min_points_input.val("#{points}")
        $max_points_input.val("0")
    else
      $fields.show();
    
    update_button_title()
    
    $points_input.change ->
      points = parseInt $points_input.val()
      min_points = parseInt $min_points_input.val()
      max_points = parseInt $max_points_input.val()
      if using_default_values
        if points >= 0
          $max_points_input.val("#{points}")
        else
          $min_points_input.val("#{points}")
      else
        if points > max_points
          $max_points_input.val("#{points}")
        if points < min_points 
          $min_points_input.val("#{points}")
      using_default_values = is_using_default_values($points_input, $min_points_input, $max_points_input)
      update_button_title()
     
          
          
    $min_points_input.change ->
      points = parseInt $points_input.val()
      min_points = parseInt $min_points_input.val()
      max_points = parseInt $max_points_input.val()
      if $min_points_input.val() == ""
        if points >= 0
          $min_points_input.val("0")
        else
          $min_points_input.val("#{points}")
      if min_points > points
        $points_input.val("#{min_points}")
      if min_points > max_points 
        $max_points_input.val("#{min_points}")
      using_default_values = is_using_default_values($points_input, $min_points_input, $max_points_input)
      update_button_title()
      
    $max_points_input.change ->
      points = parseInt $points_input.val()
      min_points = parseInt $min_points_input.val()
      max_points = parseInt $max_points_input.val()
      if $max_points_input.val() == ""
        if points >= 0
          $max_points_input.val("#{points}")
        else
          $max_points_input.val("0")
      if max_points < points
        $points_input.val("#{max_points}")
      if min_points > max_points
        $min_points_input.val("#{max_points}")
      using_default_values = is_using_default_values($points_input, $min_points_input, $max_points_input)
      update_button_title()

        
          
          
          