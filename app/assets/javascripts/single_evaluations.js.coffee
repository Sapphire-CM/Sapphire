resize_pdf_inline_containers = ->
  $pdf_inline_containers = $('.pdf-inline-container')
  if $pdf_inline_containers.length == 1
    # scale it to fully fit into window

    page_height = if window.innerHeight != null
      window.innerHeight
    else if document.body != null
      document.body.clientHeight
    else
      100 # some arbitrary default

    # topbar is 45px heigh
    remaining_height = page_height - 45

    $pdf_inline_containers.css('height', "#{remaining_height}px")
  else
    # there is more than one PDF displayed, just use a default height
    $pdf_inline_containers.css('height', '30em')

$(window).resize ->
  resize_pdf_inline_containers()

$(document).on "ready page:load", ->
  resize_pdf_inline_containers()
  $('.single-evaluation-form input').change ->
    $(this).closest("form").submit()

