# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Event
  constructor: (@element) ->
    @max_size = 97
    @animating = false
    @description = @element.find('.description')

    @check_initial_size()

  check_initial_size: ->
    if @description.length > 0
      @initial_height = @description.outerHeight()

      if @initial_height > @max_size
        @setup_collapsable()

        @collapse(false)
  setup_collapsable: ->
    @description.addClass('collapsable')
    @backdrop = $('<div>').addClass('backdrop')
    @button = $('<a>').addClass('tiny button')

    @button.click =>
      @toggle_collapse(true)

    @button.appendTo(@backdrop)
    @backdrop.appendTo(@description)

  collapse: (animated = true) ->
    return if @animating

    if animated
      self = @
      @animating = true
      @description.removeClass('expanded')
      @description.animate {height: @max_size}, 'fast', ->
        self.animating = false
        $(window).trigger('scroll')
    else
      @description.removeClass('expanded')
      @description.css('height', @max_size)
      $(window).trigger('scroll')

    @collapsed = true
    @button.text('expand')

  expand: (animated = true) ->
    return if @animating

    if animated
      self = @
      @animating = true

      @description.animate {'height': @initial_height}, 'fast', ->
        self.description.height('')
        self.animating = false
        self.description.addClass('expanded')
        $(window).trigger('scroll')
    else
      @description.height('').addClass('expanded')
      $(window).trigger('scroll')

    @collapsed = false
    @button.text('collapse')


  toggle_collapse: (animated = true) ->
    return if @animating

    if @collapsed
      @expand(animated)
    else
      @collapse(animated)

class EventLoader
  constructor: (@element) ->
    @current_page = 1
    @loading = false
    @active = true

    @loading_errors = 0
    @setup()
    @check_scroll_position()
    @events = []

  setup: ->
    @element.html('')
    @loading_url = @element.data('events-url')
    @events_list = $('<div>')
    @events_list.appendTo(@element)

    @on_scroll_function = =>
      @check_scroll_position()

    @load_more_panel = $('<div>').addClass('panel')
    load_more_link = $('<a>')
    load_more_link.text("Load more")
    load_more_link.appendTo(@load_more_panel)
    load_more_link.click =>
      @load()

    @load_more_panel.appendTo(@element)
    @load_more_panel.hide()
    $(window).on 'scroll', $.throttle(100, @on_scroll_function)
    $(document).one 'page:load', =>
      @active = false
      @remove_scroll_handler()

  load: ->
    if !@loading && @active
      @loading = true

      url = @loading_url
      if url.includes("?")
        url += "&"
      else
        url += "?"
      url += "page=#{@current_page}"

      new_entries = $.getJSON(url).done (data) =>
        @loading_errors = 0
        @loading = false
        if data.includes_entries
          @load_more_panel.show()
          @current_page += 1

          $events = $(data.events_html)
          $events.appendTo(@events_list)

          @create_events($events)

          @check_scroll_position()
        else
          @load_more_panel.hide()
          @remove_scroll_handler()
          if @current_page == 1
            @show_no_recent_activities_panel()

      .error =>
        @loading = false
        @loading_errors += 1
        if @loading_errors < 5
          self = @
          setTimeout =>
             self.check_scroll_position()
          , 200 * @loading_errors

  check_scroll_position: ->
    list_top_position = @events_list.offset().top
    list_bottom_position = list_top_position + @events_list.height()

    window_bottom = $(window).scrollTop() + $(window).height();

    if window_bottom > list_bottom_position - 200
      @load()

  remove_scroll_handler: ->
    $(window).off 'scroll', @on_scroll_function

  show_no_recent_activities_panel: ->
    panel = $('<div>').addClass('panel')
    panel.html('<strong>No recent activities</strong>')

    panel.appendTo(@element)

  create_events: ($events) ->
    self = @
    $events.each ->
      self.events.push(new Event($(@)))

$(document).ready ->
  $containers = $('.event-list-container')

  if ($containers.length > 0)
    for container in $containers
      new EventLoader($(container))

  $('label input').click ->
    $('#scope_form').submit();


$(document).on "page:change", -> 
  $scopes = $("input:checkbox")
  $scopes.each -> 
    $scope = $(this)
    if(!($scope.prop('checked')))
      $scope.parent().find('.fi-check').css('visibility', 'hidden')