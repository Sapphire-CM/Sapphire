$(document).on 'click', '#edit_comment', () ->
  $comment = $(this).closest(".comment")
  hide($comment)
  show_form($comment)

$(document).on 'click', '#edit_comment_cancel', (e) ->
  e.preventDefault()
  $form = $(this).closest('form')
  hide($form)
  show_comment($form)

$(document).on 'click', '.save.button', (e) ->
  e.preventDefault()
  $form = $(this).closest('form')
  $content = $form.find('#comment_content').val()
  $comment = $(".comment##{$form.attr('id')}")
  $comment.find('.panel').html($content)
  save_comment_changes($form, $content)
  hide($form)
  show_comment($form)

show_comment = ($e) ->
  $(".comment##{$e.attr('id')}").removeClass('hidden')

show_form = ($e) ->
  $("form##{$e.attr('id')}").removeClass('hidden')

hide = ($e) ->
  $e.addClass('hidden')

save_comment_changes = (form, data) ->
  $form = $(form)
  $url = $form.attr('action')
  $.ajax({
    method: 'PATCH',
    url: $url,
    data: { 'comment': { 'content': data } }
  })
