class LookupController
  constructor: (@element, @form_controller)->
    @_extract_lookup_url()
    @_setup_dropdown()
    @_setup_listeners()

  # =========
  # = Setup =
  # =========

  _setup_listeners: ->
    input_query = "input[name=subject_lookup]"
    that = this
    @element.on "keydown", input_query, (e) ->
      $input = $(e.target)

      if that._is_control_key_pressed(e)
        keycode = that._get_key_code(e)
        stop_event = true
        switch keycode
          when 13
            if that._is_highlight_active()
              that._select_subject(that._highlighted_subject())
              that._hide_dropdown()
            else
              stop_event = false
          when 40
            that._highlight_next()
          when 38
            that._highlight_previous()
          else
            stop_event = false
        if stop_event
          e.stopPropagation()
          e.preventDefault()

    @element.on "keyup", input_query, $.debounce 250,(e)->
      $input = $(e.target)
      value = $input.val()

      unless that._is_control_key_pressed(e)
        that._perform_lookup($input)

    @element.on "blur", input_query, ->
      that._hide_dropdown() unless that.is_hovering_dropdown
      that.is_lookup_input_focused = false
      that._reset_highlight()

    @element.on "focus", input_query, (e) ->
      $input = $(e.target)
      if $input.val() != ""
        that._perform_lookup($input)
      that.is_lookup_input_focused = true

    @dropdown.on "click", "li", (e) ->
      $li = $(this)

      id = $li.data("subject-id")
      that._select_id(id)
      that._hide_dropdown()

    @dropdown.on "mouseenter", (e) ->
      that.is_hovering_dropdown = true

    @dropdown.on "mouseleave", (e) ->
      that.is_hovering_dropdown = false
      if that.is_lookup_input_focused == false
        that._hide_dropdown()

  _setup_dropdown: ->
    @dropdown = $("<div>");
    @dropdown.addClass("submission-bulk-dropdown")
      .hide()

    @results = $("<ul>");
    @results.addClass("results").hide()

    @loading_indicator = $("<div>")
    @loading_indicator.addClass("loading-indicator-container")

    $loading_indicator = $("<div>")
    $loading_indicator.addClass("loading-indicator")
    $loading_indicator.appendTo(@loading_indicator)

    @loading_indicator.appendTo(@dropdown)
    @results.appendTo(@dropdown);

    @dropdown.appendTo($("body"));

  _extract_lookup_url: ->
    @lookup_url = @element.data("lookup-url")

  # ===================
  # = Lookup Handling =
  # ===================

  _perform_lookup: ($input)->
    value = $input.val()

    if value != ""
      @_show_dropdown($input)

      if @last_lookup != value
        @last_lookup = value
        @_reset_dropdown_data()
        @_start_loading()

        $.ajax
          type: "GET"
          url: @lookup_url
          data:
            q: value
          success: (data) =>
            @_set_dropdown_data(data)
            @_stop_loading()
            @_show_subjects()
          error: (error) =>
            @_reset_dropdown_data()
            @_stop_loading()
            @_show_error()

      else
        @_show_subjects() if @dropdown_data
    else
      @_hide_dropdown()

  _select_id: (id) ->
    selected_subject = undefined
    for subject in @dropdown_data.subjects
      if subject.id == id
        selected_subject = subject
        break

    if selected_subject
      @_select_subject(subject)

  _select_subject: (subject) ->
    row_id = @_get_item_row_id()
    @form_controller.select_subject(row_id, subject)

  # ================
  # = Dropdown UI  =
  # ================

  _show_dropdown: ($anchor)->
    pos = $anchor.offset()

    @dropdown.fadeIn("fast") if @dropdown.css('display') == 'none'
    @dropdown.css({top: pos.top + $anchor.outerHeight(), left: pos.left, width: $anchor.closest("td").width()})
    @target_loopup_input = $anchor

  _hide_dropdown: ->
    @dropdown.fadeOut("fast")
    @target_loopup_input = undefined

  _start_loading: ->
    @dropdown.addClass("loading")

  _stop_loading: ->
    @dropdown.removeClass("loading")

  _show_subjects: ->
    @_clear_results()

    if @dropdown_data.subjects.length > 0
      for row in @dropdown_data.subjects
        $li = $("<li>")
        $li.addClass("subject")
        $li.html(row.html)
        $li.attr("data-subject-id", row.id)
        $li.appendTo(@results)
    else
      $li = $("<li>")
      $li.addClass("empty")
      $li.text("No results found.")
      $li.appendTo(@results)

    if @dropdown_data.more
      $li = $("<li>")
      $li.addClass("more")
      $li.text("More results available")
      $li.appendTo(@results)
    @results.show()

  _show_error: ->
    @_clear_results()

    $li = $("<li>")
    $li.addClass("error")
    $li.text("An error occurred during loading.")
    $li.appendTo(@results)

    @results.show()

  _hide_results: ->
    @results.hide()

  _clear_results: ->
    @results.children().remove()

  # =================
  # = Dropdown Data =
  # =================

  _reset_dropdown_data: ->
    @dropdown_data = {subjects: [], more: false}
    @_reset_highlight()

  _set_dropdown_data: (data) ->
    @dropdown_data = data
    @_reset_highlight()

  # ====================
  # = Dropdown Actions =
  # ====================

  _confirm_and_blur: ->
    if @dropdown_data.subjects.length == 1
      @_select_id(@dropdown_data.subjects[0].id)

  # ======================
  # = Highlight Handling =
  # ======================

  _highlight_next: ->
    if @dropdown_data.subjects.length > 0
      if !@_is_highlight_active() || @highlight_idx + 1 >= @dropdown_data.subjects.length
        @highlight_idx = 0
      else
        @highlight_idx += 1
      @_update_highlight()

  _highlight_previous: ->
    if @dropdown_data.subjects.length > 0
      if !@_is_highlight_active() || @highlight_idx == 0
        @highlight_idx = @dropdown_data.subjects.length - 1
      else
        @highlight_idx -= 1
      @_update_highlight()

  _is_highlight_active: ->
    @highlight_idx != undefined

  _reset_highlight: ->
    @highlight_idx = undefined

  _highlighted_subject: ->
    @dropdown_data.subjects[@highlight_idx]

  _update_highlight: ->
    @dropdown.find("li.highlight").removeClass("highlight")
    if @_is_highlight_active()
      subject = @_highlighted_subject()
      @dropdown.find("li[data-subject-id=#{subject.id}]").addClass("highlight")

  # ===========
  # = Helpers =
  # ===========

  _is_control_key_pressed: (e) ->
    control_key_codes = [13, 27, 38, 40]

    code = @_get_key_code(e)
    e.altKey || e.metaKey || e.ctrlKey || control_key_codes.includes(code)

  _get_key_code: (e) ->
    e.which || e.keyCode

  _get_item_row_id: ->
    @target_loopup_input?.closest("tr").attr("data-row-id")

class ItemController
  constructor: (@element, @form_controller, @id) ->
    @_setup()

  _setup: ->
    @_setup_element()
    @_setup_edit_icon()
    @_setup_listeners()
    @_setup_initial_state()

  _setup_element: ->
    @element.attr("data-row-id", @id)

  _setup_edit_icon: ->
    $edit_icon_container = $("<div>")
    $edit_icon_container.addClass("edit-icon-container")

    $edit_icon_link = $("<a>")

    $edit_icon = $("<i>")
    $edit_icon.addClass("fi-pencil")
    $edit_icon.appendTo($edit_icon_link)

    $edit_icon_link.appendTo($edit_icon_container)

    @element.find(".subject-container").closest("td").prepend($edit_icon_container)
    @edit_icon = $edit_icon_link

  _setup_listeners: ->
    @edit_icon.on "click", (e) =>
      @_enable_lookup()
      @_focus_subject_lookup_input()

      e.stopPropagation()
      e.preventDefault()

    @element.on "click", "*[data-behaviour=remove-item]", (e) =>
      @_remove()
      e.stopPropagation()
      e.preventDefault()
    @element.on "click", "*[data-behaviour=cancel-lookup]", (e) =>
      @_cancel_lookup()
      e.stopPropagation()
      e.preventDefault()

  _setup_initial_state: ->
    if @has_subject()
      @_disable_lookup()
    else
      @_enable_lookup()

  # ====================
  # = Public Interface =
  # ====================

  set_subject: (subject) ->
    @_update_subject_description(subject.html)
    @_update_subject_id(subject.id)
    @_focus_first_input()

    @_disable_lookup()

  has_subject: ->
    @_find_subject_id_input().val() != ""

  remove_element: ->
    @element.remove()
    @element = undefined

  # ===================
  # = Lookup Handling =
  # ===================

  _enable_lookup: ->
    @_hide_edit_icon()
    @_hide_subject_description()
    @_show_subject_lookup_container()
    @_hide_removal_link()
    @_update_cancel_button_visibility()

  _disable_lookup: ->
    @_show_edit_icon()
    @_show_subject_description()
    @_hide_subject_lookup_container()
    @_show_removal_link()

  # =========================
  # = Subject Cell Handling =
  # =========================

  _find_subject_id_input: ->
    @element.find("input[data-behaviour=subject-id]")

  _update_subject_description: (description)->
    @element.find(".subject-container").html(description)

  _update_subject_id: (id) ->
    @_find_subject_id_input().val(id)

  _show_subject_description: ->
    @element.find(".subject-container").show()

  _hide_subject_description: ->
    @element.find(".subject-container").hide()

  _show_edit_icon: ->
    @edit_icon.show()

  _hide_edit_icon: ->
    @edit_icon.hide()

  # =================================
  # = Subject Lookup Input Handling =
  # =================================

  _find_subject_loopup_input: ->
    @element.find("input[name=subject_lookup]")

  _find_subject_loopup_container: ->
    @element.find(".lookup-input-container")

  _show_subject_lookup_container: ->
    @_find_subject_loopup_container().show()

  _hide_subject_lookup_container: ->
    @_find_subject_loopup_container().hide()

  _focus_subject_lookup_input: ->
    @_find_subject_loopup_input().focus()

  # ================
  # = Item Removal =
  # ================

  _remove: ->
    @form_controller.remove(this.id)

  _show_removal_link: ->
    @element.find("*[data-behaviour=remove-item]").show()

  _hide_removal_link: ->
    @element.find("*[data-behaviour=remove-item]").hide()

  # =================
  # = Cancel Button =
  # =================

  _update_cancel_button_visibility: ->
    if @has_subject()
      @_show_cancel_button()
    else
      @_hide_cancel_button()

  _show_cancel_button: ->
    $search_field_container = @_find_subject_loopup_container().find(".search-field")
    $cancel_button_container = @_find_subject_loopup_container().find(".cancel-button")

    $search_field_container.removeClass("small-12").addClass("small-9")
    $cancel_button_container.show()

  _hide_cancel_button: ->
    $search_field_container = @_find_subject_loopup_container().find(".search-field")
    $cancel_button_container = @_find_subject_loopup_container().find(".cancel-button")

    $search_field_container.addClass("small-12").removeClass("small-9")
    $cancel_button_container.hide()

  _cancel_lookup: ->
    @_disable_lookup()

  # ===========
  # = Helpers =
  # ===========

  _focus_first_input: ->
    @element.find(".string input").first().focus()

class SubmissionBulkFormController
  @id = 0
  @_get_item_id: ->
    @id += 1

  constructor: (@element) ->
    @_setup()

  _setup: ->
    @_setup_item_controllers()
    @_setup_lookup_controller()
    @_setup_new_item_template()
    @_setup_listeners()

  _setup_item_controllers: ->
    that = this
    $trs = @element.find("tr.item")

    item_controllers = []
    $trs.each ->
      $tr = $(this)
      item_controllers.push(that._build_item_controller($tr))

    @item_controllers = item_controllers

  _setup_lookup_controller: ->
    @lookup_controller = new LookupController(@element, this)

  _setup_new_item_template: ->
    @new_item_template = @element.find("*[data-behaviour=new-item-template]").data("template")

  _setup_listeners: ->
    @element.on "submit.form_controller", (e) =>
      @element.off("submit.form_controller")
      @_disable_form()


  # ===================
  # = Public Interface =
  # ===================

  select_subject: (row_id, subject) ->
    item_controller = @_find_item_controller(row_id)
    item_controller.set_subject(subject)
    @_ensure_blank_line()

  remove: (row_id) ->
    item_controller = @_find_item_controller(row_id)
    idx = @item_controllers.indexOf(item_controller)

    if idx != -1
      item_controller.remove_element()
      @item_controllers.splice(idx, 1)

  # ===========
  # = Helpers =
  # ===========
  _ensure_blank_line: ->
   @_add_new_item() if @item_controllers[@item_controllers.length - 1].has_subject()

  _add_new_item: ->
    id = SubmissionBulkFormController._get_item_id()
    template = @new_item_template.replace(/\[new_item\]/g, "[#{id}]")

    $item = $(template)
    $item.appendTo(@element.find("tbody"))

    controller = @_build_item_controller($item, id)
    @item_controllers.push(controller)


  _build_item_controller: ($element, id = SubmissionBulkFormController._get_item_id()) ->
    new ItemController($element, this, id)

  _find_item_controller: (id)->
    for item_controller in @item_controllers
      return item_controller if item_controller.id == parseInt(id)
    undefined

  _disable_form: ->
    @element.find("input").addClass("disabled")
    @element.find("input.button").attr("disabled", "disabled")


$(document).on "page:load ready", ->
  $forms = $("form.submission-bulk")

  if $forms.length > 0
    $forms.each ->
      $form = $(this)

      new SubmissionBulkFormController($form)