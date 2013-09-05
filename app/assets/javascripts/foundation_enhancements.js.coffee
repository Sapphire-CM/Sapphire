
# self-closing dropdowns
$(document).on "click", ".f-dropdown a", (e)->
  id = $(@).closest(".f-dropdown").first().attr("id")
  $("a[data-dropdown=#{id}]").trigger("click")