shared_dropdown_element = undefined

class DropdownElement
  @instance: ->
    shared_dropdown_element ||= new DropdownElement()

  @clear_instance: ->
    shared_dropdown_element = undefined

  constructor: ->
    @_setup_initial_state()
    @_create_element()
    @_setup_listeners()

  # =========
  # = Setup =
  # =========

  _setup_initial_state: ->
    @is_hovering = false

  _create_element: ->
    @element = $("<div>");
    @element.addClass("association-lookup-dropdown")
      .hide()

    @results = $("<ul>");
    @results.addClass("results").hide()

    @loading_indicator = $("<div>")
    @loading_indicator.addClass("loading-indicator-container")

    $loading_indicator = $("<div>")
    $loading_indicator.addClass("loading-indicator")
    $loading_indicator.appendTo(@loading_indicator)

    @loading_indicator.appendTo(@element)
    @results.appendTo(@element);

    @element.appendTo($("body"));

  _setup_listeners: ->
    that = this
    @element.on "mouseenter", (e) ->
      that.is_hovering = true

    @element.on "mouseleave", (e) ->
      that.is_hovering = false
      if that.hide_after_mouseleave
        that.hide()

    @element.on "click", "li.subject", (e)->
      $this = $(@)
      idx = $this.data("subject-idx")
      subject = that.data.subjects[idx]
      that._select(subject)

  # ====================
  # = Public Interface =
  # ====================

  hide_unless_hovering: ->
    if @is_hovering
      @hide_after_mouseleave = true
    else
      @hide()

  attach_to: (@anchor, @delegate) ->
    @hide_after_mouseleave = false
    pos = @anchor.offset()

    @element.fadeIn("fast") if @element.css('display') == 'none'
    @element.css({top: pos.top + @anchor.outerHeight(), left: pos.left, width: @anchor.closest("td").width()})

  hide: ->
    @element.fadeOut("fast")
    @anchor = undefined
    @hide_after_mouseleave = true

  start_loading: ->
    @element.addClass("loading")

  stop_loading: ->
    @element.removeClass("loading")

  # Data Handling

  reset_data: ->
    @data = { subjects: [], more: false }

  show_data: (@data) ->
    @_clear_results()

    if @data.subjects.length > 0
      for row, idx in @data.subjects
        $li = $("<li>")
        $li.addClass("subject")
        $li.html(row.html)
        $li.attr("data-subject-idx", idx)

        $li.appendTo(@results)
    else
      $li = $("<li>")
      $li.addClass("empty")
      $li.text("No results found.")
      $li.appendTo(@results)

    if @data.more
      $li = $("<li>")
      $li.addClass("more")
      $li.text("More results available")
      $li.appendTo(@results)
    @results.show()
    @reset_highlight()

  show_error: ->
    @_clear_results()

    $li = $("<li>")
    $li.addClass("error")
    $li.text("An error occurred during loading.")
    $li.appendTo(@results)

    @results.show()

  hide_results: ->
    @results.hide()

  # Highlight Handling
  select_highlighted: ->
    @_select(@highlighted_subject())

  highlight_next: ->
    if @data.subjects.length > 0
      if !@is_highlight_active() || @highlight_idx + 1 >= @data.subjects.length
        @highlight_idx = 0
      else
        @highlight_idx += 1
      @_update_highlight()

  highlight_previous: ->
    if @data.subjects.length > 0
      if !@is_highlight_active() || @highlight_idx == 0
        @highlight_idx = @data.subjects.length - 1
      else
        @highlight_idx -= 1
      @_update_highlight()

  is_highlight_active: ->
    @highlight_idx != undefined

  reset_highlight: ->
    @highlight_idx = undefined
    @_update_highlight()

  highlighted_subject: ->
    @data.subjects[@highlight_idx]

  # ===================
  # = Private Helpers =
  # ===================

  _update_highlight: ->
    @element.find("li.highlight").removeClass("highlight")
    if @is_highlight_active()
      @element.find("li[data-subject-idx=#{@highlight_idx}]").addClass("highlight")


  _clear_results: ->
    @results.children().remove()

  _select: (subject)->
    @delegate?.select_subject(@, subject)

class LookupController
  constructor: (@element, @delegate)->
    @_setup_listeners()

  # =========
  # = Setup =
  # =========

  _setup_listeners: ->
    that = this
    @element.on "keydown", (e) ->
      $input = $(e.target)

      if that._is_control_key_pressed(e)
        keycode = that._get_key_code(e)
        stop_event = true
        switch keycode
          when 13 # enter
            if DropdownElement.instance().is_highlight_active()
              DropdownElement.instance().select_highlighted()
              DropdownElement.instance().hide()
            else
              stop_event = false
          when 27 # esc
            DropdownElement.instance().hide()
            that.delegate?.cancel_lookup(that)
          when 40 # down
            DropdownElement.instance().highlight_next()
          when 38 # up
            DropdownElement.instance().highlight_previous()
          else
            stop_event = false
        if stop_event
          e.stopPropagation()
          e.preventDefault()

    @element.on "keyup", $.debounce 250,(e)->
      $input = $(e.target)
      value = $input.val()

      unless that._is_control_key_pressed(e)
        that._perform_lookup($input)

    @element.on "blur", ->
      DropdownElement.instance().hide_unless_hovering()
      DropdownElement.instance().reset_highlight()

    @element.on "focus", (e) ->
      that._perform_lookup()

  # ====================
  # = Public Interface =
  # ====================

  select_subject: (dropdown, subject) ->
    @_select_subject(subject)
    DropdownElement.instance().hide()


  # ===================
  # = Lookup Handling =
  # ===================

  _perform_lookup: ()->
    value = @element.val()

    if value != ""
      DropdownElement.instance().attach_to(@element, @)
      DropdownElement.instance().reset_data()
      DropdownElement.instance().start_loading()

      $.ajax
        type: "GET"
        url: @delegate?.lookup_url()
        data:
          q: value
        success: (data) =>
          DropdownElement.instance().stop_loading()
          DropdownElement.instance().show_data(data)
        error: (error) =>
          DropdownElement.instance().reset_data()
          DropdownElement.instance().stop_loading()
          DropdownElement.instance().show_error()
    else
      DropdownElement.instance().hide()

  _select_subject: (subject) ->
    @delegate.select_subject(@, subject)

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
    @target_lookup_input?.closest("tr").attr("data-row-id")

class ListItemController
  constructor: (@element, @form_controller, @id) ->
    @_setup()

  _setup: ->
    @_setup_element()
    @_setup_edit_icon()
    @_setup_listeners()
    @_setup_lookup_controller()
    @_setup_initial_state()

  _setup_element: ->
    @element.attr("data-row-id", @id)

  _setup_edit_icon: ->
    $edit_icon_container = $("<div>")
    $edit_icon_container.addClass("edit-icon-container")

    $edit_icon_link = $("<a>").attr("data-behaviour", "edit-subject")

    $edit_icon = $("<i>")
    $edit_icon.addClass("fi-pencil")
    $edit_icon.appendTo($edit_icon_link)

    $edit_icon_link.appendTo($edit_icon_container)

    @element.find(".subject-container").closest("td").prepend($edit_icon_container)
    @edit_icon = $edit_icon_link

  _setup_lookup_controller: ->
    $input = @_find_subject_lookup_input()
    @lookup_controller = new LookupController($input, @)

  _setup_listeners: ->
    @element.on "click", "*[data-behaviour=edit-subject]", (e) =>
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
    unless @form_controller.is_autoadd_active()
      @_show_removal_link()

    if @has_subject()
      @_disable_lookup()
    else
      @_enable_lookup()


  # ====================
  # = Public Interface =
  # ====================

  has_subject: ->
    @_find_subject_id_input().val() != ""

  remove_element: ->
    if @_use_soft_removal()
      @_soft_remove_element()
    else
      @_hard_remove_element()

  focus_lookup: ->
    @_find_subject_lookup_input().focus()

  # Lookup Delegate
  select_subject: (lookup_controller, subject) ->
    @_update_subject_description(subject.html)
    @_update_subject_id(subject.id)
    @_focus_first_input()

    @_disable_lookup()
    @form_controller.select_subject(@, subject)

  cancel_lookup: (lookup_controller) ->
    @_cancel_lookup() if @has_subject()

  lookup_url: ->
    @form_controller.lookup_url()

  # ===================
  # = Lookup Handling =
  # ===================

  _enable_lookup: ->
    @_hide_edit_icon()
    @_hide_subject_description()
    @_show_subject_lookup_container()
    @_hide_removal_link() if @form_controller.is_autoadd_active()
    @_update_cancel_button_visibility()

  _disable_lookup: ->
    @_show_edit_icon()
    @_show_subject_description()
    @_hide_subject_lookup_container()
    @_show_removal_link() if @form_controller.is_autoadd_active()

  # =========================
  # = Subject Cell Handling =
  # =========================

  _find_subject_lookup_input: ->
    @element.find("input[name=subject_lookup]")

  _find_subject_id_input: ->
    @element.find("input[data-behaviour=association-id]")

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

  _find_subject_lookup_input: ->
    @element.find("input[name=subject_lookup]")

  _find_subject_lookup_container: ->
    @element.find(".lookup-input-container")

  _show_subject_lookup_container: ->
    @_find_subject_lookup_container().show()

  _hide_subject_lookup_container: ->
    @_find_subject_lookup_container().hide()

  _focus_subject_lookup_input: ->
    @_find_subject_lookup_input().focus()

  # ================
  # = Item Removal =
  # ================

  _remove: ->
    @form_controller.remove(this.id)

  _show_removal_link: ->
    @element.find("*[data-behaviour=remove-item]").show()

  _hide_removal_link: ->
    @element.find("*[data-behaviour=remove-item]").hide()

  _hard_remove_element: ->
    @element.remove()
    @element = undefined

  _soft_remove_element: ->
    @element.find("input[data-behaviour=item-is-removed]").val("1")
    @element.hide()

    # Fix alternating table backgrounds - move this <tr> out of the way
    $thead = @element.closest("table").find("thead")
    @element.appendTo($thead)

    @element = undefined

  _use_soft_removal: ->
    @_is_persisted()

  _is_persisted: ->
    @element.data("persisted")

  # =================
  # = Cancel Button =
  # =================

  _update_cancel_button_visibility: ->
    if @has_subject()
      @_show_cancel_button()
    else
      @_hide_cancel_button()

  _show_cancel_button: ->
    $search_field_container = @_find_subject_lookup_container().find(".search-field")
    $cancel_button_container = @_find_subject_lookup_container().find(".cancel-button")

    $search_field_container.removeClass("small-12").addClass("small-9")
    $cancel_button_container.show()

  _hide_cancel_button: ->
    $search_field_container = @_find_subject_lookup_container().find(".search-field")
    $cancel_button_container = @_find_subject_lookup_container().find(".cancel-button")

    $search_field_container.addClass("small-12").removeClass("small-9")
    $cancel_button_container.hide()

  _cancel_lookup: ->
    @_disable_lookup()

  # ===========
  # = Helpers =
  # ===========

  _focus_first_input: ->
    @element.find(".string input").first().focus()

class AssociationListLookupFormController
  @id = 0
  @_get_item_id: ->
    @id += 1

  constructor: (@element) ->
    @_setup()

  _setup: ->
    @_setup_options()
    @_setup_item_controllers()
    @_setup_new_item_template()
    @_setup_listeners()

  _setup_options: ->
    @ensure_blank_line = @element.data("ensure-blank-line")

  _setup_item_controllers: ->
    that = this
    $trs = @element.find(".association-item")

    item_controllers = []
    $trs.each ->
      $tr = $(this)
      item_controllers.push(that._build_item_controller($tr))

    @item_controllers = item_controllers

  _setup_new_item_template: ->
    @new_item_template = @element.find("*[data-behaviour=new-item-template]").data("template")

  _setup_listeners: ->
    @element.on "submit.form_controller", (e) =>
      @element.off("submit.form_controller")
      @_disable_form()

    @element.on "click", "a[data-behaviour=add-item]", =>
      controller = @_add_new_item()
      controller.focus_lookup()

  # ===================
  # = Public Interface =
  # ===================

  lookup_url: ->
    @_lookup_url ||= @element.data("lookup-url")

  select_subject: (list_item_controller, subject) ->
    @_ensure_blank_line() if @ensure_blank_line

  remove: (row_id) ->
    item_controller = @_find_item_controller(row_id)
    idx = @item_controllers.indexOf(item_controller)

    if idx != -1
      item_controller.remove_element()
      @item_controllers.splice(idx, 1)

  is_autoadd_active: ->
    @ensure_blank_line

  # ===========
  # = Helpers =
  # ===========

  _ensure_blank_line: ->
     @_add_new_item() if @item_controllers[@item_controllers.length - 1].has_subject()

  _add_new_item: ->
    id = AssociationListLookupFormController._get_item_id()
    template = @new_item_template.replace(/\[new_item\]/g, "[#{id}]")

    $item = $(template)
    $item.appendTo(@element.find("tbody"))

    controller = @_build_item_controller($item, id)
    @item_controllers.push(controller)
    controller

  _build_item_controller: ($element, id = AssociationListLookupFormController._get_item_id()) ->
    new ListItemController($element, this, id)

  _find_item_controller: (id)->
    for item_controller in @item_controllers
      return item_controller if item_controller.id == parseInt(id)
    undefined

  _disable_form: ->
    @element.find("input").addClass("disabled")
    @element.find("input.button").attr("disabled", "disabled")


class AssociationLookupInputController
  constructor: (@element) ->
    @_setup()

  _setup: ->
    @_setup_lookup_controller()
    @_setup_listeners()

  _setup_lookup_controller: ->
    @lookup_controller = new LookupController(@element, this)

  _setup_listeners: ->
    @element.find("[data-behaviour=start-lookup]").click (e)=>
      e.preventDefault()
      e.stopPropagation()

  # ==============================
  # = Lookup Controller Delegate =
  # ==============================

  lookup_url: ->
    @_lookup_url ||= @element.data("lookup-url")

  select_subject: (lookup_controller, subject) ->
    @_select_subject(subject)

  # ===================
  # = Private Helpers =
  # ===================

  _select_subject: (subject)->
    @_update_input(subject.id)
    @_update_subject_container(subject.html)

  _update_input: (value)->
    $input = $(@element.data("input"))
    $input.val(value)

  _update_subject_container: (html) ->
    $container = $(@element.data("subject-container"))
    $container.html(html)

$(document).on "page:load ready", ->
  DropdownElement.clear_instance()

  $list_forms = $("form[data-behaviour=association-list-lookup]")
  if $list_forms.length > 0
    $list_forms.each ->
      $form = $(this)

      new AssociationListLookupFormController($form)

  $lookup_inputs = $("input[data-behaviour=association-lookup]")
  if $lookup_inputs.length > 0
    $lookup_inputs.each ->
      $input = $(this)

      new AssociationLookupInputController($input)