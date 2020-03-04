$(document).on 'click', "[id^=comment_save_evaluation]", () ->
  $("##{evaluation_comment_button($(this))}").removeClass('secondary')

$(document).on 'click', "[id^=comment_delete_evaluation]", () ->
  $comments = $(this).closest('.comments_list')
  if($comments.find('.comment').length == 1)
    $("##{evaluation_comment_button($(this))}").addClass('secondary')

evaluation_comment_button = (button) ->
  id = $(button).attr('id').split('_').pop()
  button_id = "comment_button_evaluation_#{id}"
