# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  get_rating_group_id = ($rating_group)->
    $rating_group.attr("id").replace("rating_group_id_", "")

  get_rating_id = ($rating) ->
    $rating.attr("id").replace("rating_id_", "")

  $('#rating_group_index_entries').sortable(
    items: ".rating_group.index_entry"
    helper: 'clone'
    forcePlaceholderSize: true
    placeholder: 'rating-group-sortable-placeholder'

    start: (e, ui) ->
      ui.helper.addClass('rating-group-sortable-helper')
      ui.placeholder.html('&nbsp;')
      ui.placeholder.show()

    update: (e, ui) ->
      post_url = $(ui.item).data('update-position-action')
      data = rating_group: {row_order_position: ui.item.index()-1}
      $.post(post_url, data)

  ).disableSelection()

  $('.rating_group.index_entry').each (i, el) ->
    $rating_group = $ el

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
        ui.placeholder.html('<td colspan="' + cellCount + '" class="rating-sortable-placeholder">&nbsp;</td>')
        ui.placeholder.show()

      update: (e, ui) ->
        $this = $(this)
        current_rg_id = get_rating_group_id $this.parents(".rating_group")
        new_rg_id = get_rating_group_id ui.item.parents(".rating_group")

        if current_rg_id == new_rg_id
          post_url = $(ui.item).data('update-position-action')
          data = rating: {rating_group_id: current_rg_id, position: ui.item.index()}
          $.post post_url, data, (result) ->
            $this.data('update-position-action', result)

      over: (e,ui)->
        ui.placeholder.insertBefore($(this).children('tr.last_one, tr.index_entry_none').first())

    ).disableSelection()
