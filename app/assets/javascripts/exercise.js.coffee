# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  $('.rating_group').each (i, el) ->
    $rating_group = $ el
    # $rating_group.find('tr.index_entry.rating').children("td").each ->
    #   $this = $(this)
    #   console.log("setting...")
    #   $this.width($this.width())
    
    get_rating_group_id = ($rating_group)->
      $rating_group.attr("id").replace("rating_group_id_", "")
    
    get_rating_id = ($rating) ->
      $rating.attr("id").replace("rating_id_", "")

    
    $ratings = $rating_group.find('table tbody').sortable(
      items: 'tr.index_entry.rating'
      distance: 20
      helper: 'clone'
      forcePlaceholderSize: true
      placeholder: 'rating-sortable-helper'
      connectWith: '.rating_group table tbody'
      start: (e, ui) ->
        ui.helper.find('.buttons-column').hide()
        ui.helper.addClass('rating-sortable-helper')
        cellCount = 0;
        $('td, th', ui.helper).each ->
          colspan = 1;
          colspanAttr = $(this).attr('colspan');
          if (colspanAttr > 1)
            colspan = colspanAttr;
          cellCount += colspan;
        ui.placeholder.show()
        ui.placeholder.html('<td colspan="' + cellCount + '" class="rating-sortable-placeholder">&nbsp;</td>')
        
      update: (e, ui) ->
        $this = $(this)
        current_rg_id = get_rating_group_id $this.parents(".rating_group")
        new_rg_id = get_rating_group_id ui.item.parents(".rating_group")
        
        if current_rg_id == new_rg_id 
          r_id = get_rating_id(ui.item)
          data = rating: {position: ui.item.index()}
          $.post(window.location + "/rating_groups/#{current_rg_id}/ratings/#{r_id}/update_position", data)
      over: (e,ui)->
        ui.placeholder.insertBefore($(this).children('tr.last_one, tr.index_entry_none').first())
        
    ).disableSelection()
  