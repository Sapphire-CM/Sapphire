# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $tables = $("table.mapping_table")
  if $tables.length > 0
    $tables.each ->
      $table = $(this)
      $selects = $table.find("select")      
      $selects.change (e) ->
        $changed_select = $(this)
        new_value = $changed_select.val()
        
        $selects.each ->
          $sel = $(this)
          if $sel.val() == new_value
            $sel.val("")
        
        $changed_select.val(new_value)
        true