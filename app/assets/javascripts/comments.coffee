$(document).on 'click', "[id^=explanations_comment_save]", () ->
  $("##{evaluation_comment_button($(this))}").removeClass('secondary')
  $("##{evaluation_comment_button($(this))}").addClass('annotate')
  count = comment_count($(this))
  $("##{evaluation_comment_button($(this))}").html('Explanations (' + (count + 1) + ')')

$(document).on 'click', "[id^=explanations_comment_delete]", () ->
  count = comment_count($(this))
  if(count == 1)
    $("##{evaluation_comment_button($(this))}").removeClass('annotate')
    $("##{evaluation_comment_button($(this))}").addClass('secondary')
    $("##{evaluation_comment_button($(this))}").html('Explanations')
  else
    $("##{evaluation_comment_button($(this))}").html('Explanations (' + (count - 1) + ')')

$(document).on 'click', "[id^=feedback_comment_save]", () ->
  $("[id^=feedback_button]").addClass('annotate')
  count = comment_count($(this))
  $("[id^=feedback_button]").html('Feedback (' + (count + 1) + ')')

$(document).on 'click', "[id^=feedback_comment_delete]", () ->
  count = comment_count($(this))
  if(count == 1)
    $("[id^=feedback_button]").removeClass('annotate')
    $("[id^=feedback_button]").html('Add Feedback')
  else
    $("[id^=feedback_button]").html('Feedback (' + (count - 1) + ')')

$(document).on 'click', "[id^=internal_notes_comment_save]", () ->
  $("[id^=internal_notes_button]").addClass('internal')
  count = comment_count($(this))
  $("[id^=internal_notes_button]").html('Internal Notes (' + (count + 1) + ')')

$(document).on 'click', "[id^=internal_notes_comment_delete]", () ->
  count = comment_count($(this))
  if(count == 1)
    $("[id^=internal_notes_button]").removeClass('internal')
    $("[id^=internal_notes_button]").html('Add Internal Note')
  else
    $("[id^=internal_notes_button]").html('Internal Notes (' + (count - 1) + ')')

evaluation_comment_button = (button) ->
  id = $(button).attr('id').split('_').pop()
  button_id = "comment_button_evaluation_#{id}"

comment_count = (button) ->
  $(button).closest('#reveal_modal_content').find('.comments_list').find('.comment').length
