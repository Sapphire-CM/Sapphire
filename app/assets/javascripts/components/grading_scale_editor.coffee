class StopEditor
  constructor: (@element, @gradingScaleEditor) ->
    @_setup()

  _setup: ->
    @_setupElement()
    @_setupListeners()

  _setupElement: ->
    @element.addClass("stop-editor")

    @input = $("<input>")
    @element.append(@input)

  _setupListeners: ->
    @input.on("blur", => @save())
    @input.on("keydown", (e) =>
      switch e.which
        when 13 then @save()   # Enter
        when 27 then @close()  # ESC
    )

  # ====================
  # = Public Interface =
  # ====================

  open: (@stop)->
    @element.addClass("open")
    @_moveTo(@stop)
    @input.val(@stop.points).focus()

  save: ->
    points = +@input.val()
    @gradingScaleEditor.updateStopPoints(@stop, points)
    @close()

  close: ->
    @element.removeClass("open")

  isOpen: ->
    @element.is(".open")

  # ==================
  # = Helper Methods =
  # ==================

  _moveTo: (stop) ->
    inChartPosition = @gradingScaleEditor.yScale(stop.points)
    offset = inChartPosition + @gradingScaleEditor.padding.top - @input.height() / 2

    @element.css({top: offset})

class GradingScaleSerializer
  serialize: (scales) ->
    {
      grading_scales: {
        grading_scale_attributes: @_serializeScales(scales)
      }
    }

  _serializeScales: (scales) ->
    for scale in scales
      {
        id: scale.id,
        min_points: scale.min_points,
        max_points: scale.max_points
      }

class GradingScaleEditor
  padding: {
    top: 35,
    left: 50,
    bottom: 15,
    right: 80
  }
  bar: {
    heightPerPoint: 3,
    padding: 1
  }
  options: {
    showGrid: false,
    showSignificantPoints: true,
  }
  resolutions: [1, 5, 10, 20, 50]
  mousePosition: {x: 0, y: 0, points: 0}
  labelPadding: 2
  minimumDragDistance: 7
  minimumOpenDistance: 10
  collapsedBackgroundSize: 5
  constructor: (@element) ->
    @_setup()

  # =========
  # = Setup =
  # =========

  _setup: ->
    @_setInitialValues()

    @_loadData()
    @_calculateSignificantPoints()
    @_calculateStops()
    @_registerGlobalListeners()

    @_setupElement()
    @_setupSVG()
    @_setupScales()
    @_setupChart()
    @_setupChartLabels()

    @_setupStopEditor()

    @_updateResolutedData()
    @_updateSizes()
    @_updateScaleDomains()
    @_updateScaleRanges()
    @_updateSubmitButton()

    @_registerChartListeners()

    @_render()

  _setInitialValues: ->
    @resolution = @resolutions[0]
    @tickInterval = 10

  _loadData: ->
    @data = @element.data("distribution")
    @scales = @element.data("scales")
    @maximumPoints = @element.data("max-points")
    @update_url = @element.data("update-url")

  _setupElement: ->
    template = """
      <div>
        <div class='row'>
          <div class='small-3 columns'>
            <label>Resolution</label>
            <div class='res-selector'></div>
          </div>
          <div class='small-3 columns grid-toggle'>
            <label for='significant-points-toggler'>Significant Points</label>
            <div class='significant-points-toggler'>
              <input type='checkbox' id='significant-points-toggler' value='1'/>
            </div>
          </div>
          <div class='small-2 columns grid-toggle'>
            <label for='grid-toggler'>Grid</label>
            <div class='grid-toggler'>
              <input type='checkbox' id='grid-toggler' value='1'/>
            </div>
          </div>
          <div class='small-4 columns'>
            <form method='PUT' class='update-form'>
              <button class='small small-12 submit'>Save Changes</button>
            </form>
          </div>
        </div>
        <div class='canvas'></div>
      </div>
    """

    @element.html(template)

    $resolutionSelectContainer = @element.find(".res-selector")
    $tickSelectContainer = @element.find(".tick-selector")

    @gridToggler = @element.find("input#grid-toggler").prop("checked", @options.showGrid)
    @significantPointsToggler = @element.find("input#significant-points-toggler").prop("checked", @options.showSignificantPoints)
    @submitButton = @element.find("button.submit")
    @resolutionSelect = @_buildResolutionSelect().appendTo($resolutionSelectContainer)

    @svgContainer = @element.find(".canvas")

  _setupSVG: ->
    @svg = d3.select(@svgContainer[0]).append("svg")

    @chartGroup = @svg.append("g")

    @tickLinesGroup = @chartGroup.append("g").attr("class", "tick-lines")

    @stopBackgroundsGroup = @chartGroup.append("g").attr("class", "stop-backgrounds")
    @barsGroup = @chartGroup.append("g").attr("class", "bars")
    @stopsGroup = @chartGroup.append("g").attr("class", "stops")

    @axesGroup = @chartGroup.append("g").attr("class", "axes")

    @yAxisGroup = @axesGroup.append("g")
    @xAxisGroup = @axesGroup.append("g")

    @significantPointsGroup = @chartGroup.append("g").attr("class", "significant-points")

    @chartLabelsGroup = @chartGroup.append("g").attr("class", "chart-labels")
    @dragLabelsGroup = @chartGroup.append("g").attr("class", "drag-labels")
    @cursorGroup = @chartGroup.append("g").attr("class", "cursors")

  _setupScales: ->
    @yScale = d3.scaleLinear()
    @xScale = d3.scaleLinear()
    @colorScale = d3.scaleOrdinal(d3.schemeCategory10)

  _setupChart: ->
    @chartGroup.attr("transform", "translate(#{[@padding.left, @padding.top]})")

  _setupChartLabels: ->
    yOffset = -25
    @positiveChartLabel = @chartLabelsGroup.append("text").attr("class", "label negative-grades").attr("y", yOffset).text("Negative")
    @negativeChartLabel = @chartLabelsGroup.append("text").attr("class", "label positive-grades").attr("y", yOffset).text("Positive")
    @noStudentsLabel = @chartLabelsGroup.append("text").attr("class", "label").attr("y", yOffset).text("No. Students")

  _setupStopEditor: ->
    $element = $("<div>")
    @element.find(".canvas").append($element)
    @stopEditor = new StopEditor($element, @)

  # ===========
  # = Helpers =
  # ===========

  _buildResolutionSelect: ->
    $select = $("<select>")
    for res in @resolutions
      $option = $("<option>")
      $option.text("#{res} Point#{if res != 1 then "s" else ""}")
      $option.attr("value", res)
      $option.appendTo($select)
    $select

  _updateSizes: ->
    @width = @element.width()
    @height = @maximumPoints * @bar.heightPerPoint + @padding.top + @padding.bottom

    @innerWidth = @width - @padding.left - @padding.right
    @innerHeight = @height - @padding.top - @padding.bottom

    @svg.attr("width", @width)
      .attr("height", @height)

  # ==================
  # = Event Handling =
  # ==================

  _onResolutionChanged: ->
    @_updateResolutedData()
    @_updateScaleDomains()

    @_render()

  _onWindowResized: ->
    @_updateSizes()
    @_updateScaleRanges()

    @_render()

  _onMouseEnteredSVG: ->
    @hovering = true
    @_updateMousePosition()
    @_renderCursor()

  _onMouseLeaveSVG: ->
    @hovering = false
    @_renderCursor()

  _onMouseMoveSVG: ->
    @_updateMousePosition()

    if @draggedStop
      @updateStopPoints(@draggedStop, @mousePosition.points)

    @_updateHoveredStop()
    @_updateMouseCursor()

    @_renderStopBgs()
    @_renderCursor()
    @_renderDragLabels()

  _onMouseDownSVG: ->
    @_startDrag()
    if d3.event.altKey
      @_render()

  _onMouseUpSVG: ->
    @_stopDrag()
    @_render()

  _onDoubleClick: ->
    if stop = @_getStopAtMousePosition(@minimumOpenDistance)
      @_openPointsEditor(stop)

  _onGridToggled: (active)->
    @options.showGrid = active
    @_render()

  _onSignificantPointsToggled: (active) ->
    @options.showSignificantPoints = active
    @_render()

  _onSubmitClicked: ->
    @_submitScales()

  # =================
  # = Drag Handling =
  # =================

  _startDrag: ->
    if stop = @_getStopAtMousePosition()
      stop.isDragged = true
      @draggedStop = stop

  _stopDrag: ->
    if @draggedStop
      @draggedStop.isDragged = false
    @draggedStop = undefined

  # ==================
  # = Scale Handling =
  # ==================

  _updateScaleDomains: ->
    maxPointValue = 0
    maxNegative = 0
    maxPositive = 0

    for datum in @resolutedData
      pointsPlusResolution = datum.points + @resolution

      maxPositive = datum.positive if datum.positive > maxPositive
      maxNegative = datum.negative if datum.negative > maxNegative
      maxPointValue = pointsPlusResolution if pointsPlusResolution > maxPointValue

    maxPoints = if @maximumPoints < maxPointValue then maxPointValue - 1 else @maximumPoints

    @xScale.domain([-maxNegative, maxPositive])
    @yScale.domain([maxPoints, 0])

  _updateScaleRanges: ->
    @yScale.range([0, @innerHeight])
    @xScale.range([10, @innerWidth - 30])

  # ===================
  # = Data Management =
  # ===================

  _updateResolutedData: ->
    resoluted = {}

    for datum in @data
      key = Math.floor(datum.points / @resolution)
      unless resoluted[key]
        resoluted[key] = {
          points: key * @resolution,
          negative: 0,
          positive: 0
        }
      resoluted[key].positive += datum.positive
      resoluted[key].negative += datum.negative

    @resolutedData = Object.values(resoluted)

  _findDatumAt: (points) ->
    @resolutedData.filter((d) => d.points <= points && points < d.points + @resolution)[0]

  _studentsInRange: (range) ->
    from = range.min_points
    to = range.max_points

    reducer = (sum, datum) => sum + datum.positive

    @data.filter((d) => from <= d.points && d.points <= to)
      .reduce(reducer, 0)

  # ==================
  # = Mouse Handling =
  # ==================

  _updateMouseCursor: ->
    @svg.classed("draggable", @_getStopAtMousePosition() != undefined)

  _updateMousePosition: ->
    [x, y] = d3.mouse(@svg.node())

    @mousePosition.x = x
    @mousePosition.y = y
    @mousePosition.points = @_getMousePositionInPoints()

  _getMousePositionInPoints: ->
    [x, y] = d3.mouse(@svg.node())

    unclampedPoints = Math.round(@yScale.invert(y - @padding.top))
    Math.min(Math.max(unclampedPoints, 0), @yScale.domain()[0])

  # =================
  # = Stop Handling =
  # =================

  _calculateStops: ->
    sortedScales = @scales.sort((a,b) -> b.min_points - a.min_points)

    @stops = for aboveScale, idx in sortedScales[0..-2]
      {
        above: aboveScale,
        below: sortedScales[idx + 1],
        points: aboveScale.min_points,
        isDragged: false
        highlighted: false,
        dirty: false
      }

  _updateStopPoints: (stop, points) ->
    if points > stop.above.max_points - 1
      points = stop.above.max_points - 1

    if points < stop.below.min_points + 1
      points = stop.below.min_points + 1

    dirty = stop.dirty || stop.points != points

    stop.points = points
    stop.above.min_points = points
    stop.below.max_points = points - 1
    stop.dirty = dirty

  _getStopAtMousePosition: (distance = @minimumDragDistance)->
    stop = @_closestStop(@mousePosition.points)

    if stop && Math.abs(@yScale(stop.points) - @yScale(@mousePosition.points)) <= distance
      stop
    else
      undefined

  _closestStop: (points) ->
    @stops.slice(0).sort((a, b) => Math.abs(a.points - points) - Math.abs(b.points - points))[0]

  _updateHoveredStop: ->
    stop.isHovered = false for stop in @stops

    @_getStopAtMousePosition()?.isHovered = true

  # ======================
  # = Significant Points =
  # ======================

  _calculateSignificantPoints: ->
    @significantPoints = []
    @significantPoints.push({name: "Max.", points: @maximumPoints})
    @significantPoints.push({name: "Half", points: Math.round(@maximumPoints / 2)})

  # =======================
  # = Submission Handling =
  # =======================

  _updateSubmitButton: ->
    disabled = @stops.filter((d) => d.dirty).length == 0

    @submitButton.prop("disabled", disabled)

  _submitScales: ->
    serializer = new GradingScaleSerializer()
    params = serializer.serialize(@scales)

    $.ajax(@update_url, {
      method: "PUT",
      data: params,
      success: ->
        Turbolinks.visit(window.location)
    })

  # =================
  # = Points Editor =
  # =================

  _openPointsEditor: (stop) ->
    @stopEditor.open(stop)

  # =============
  # = Rendering =
  # =============

  _render: ->
    @_renderChartLabels()
    @_renderAxes()
    @_renderTickLines()
    @_renderPositiveBars()
    @_renderNegativeBars()

    @_renderStops()
    @_renderStopBgs()

    @_renderDragLabels()

    @_renderSignificantPoints()

  _renderChartLabels: ->
    positiveChartLabelWidth = @positiveChartLabel.node().getBBox().width

    @positiveChartLabel.attr("x", @xScale(0) - @labelPadding * 2)
    @negativeChartLabel.attr("x", @xScale(0) + @labelPadding * 2)
    @noStudentsLabel.attr("x", @xScale(0) + @labelPadding * 4 + positiveChartLabelWidth)

  _renderAxes: ->
    xAxis = d3.axisTop(@xScale).tickFormat((d) => Math.abs(d))
    yAxis = d3.axisLeft(@yScale).ticks(Math.floor(@yScale.domain()[0] / @tickInterval))

    @xAxisGroup.call(xAxis)
    @yAxisGroup.attr("transform", "translate(#{[@xScale(0), 0]})").call(yAxis)

  _renderTickLines: ->
    tickData = if @options.showGrid
      @xScale.ticks()
    else
     []

    tickLines = @tickLinesGroup.selectAll(".line").data(tickData)
    tickLinesEnter = tickLines.enter().append("line").attr("class", "line")
    tickLines.exit().remove()

    tickLines.merge(tickLinesEnter)
      .attr("x1", (d) => @xScale(d))
      .attr("x2", (d) => @xScale(d))
      .attr("y1", 0)
      .attr("y2", @innerHeight)

  _renderPositiveBars: ->
    bars = @barsGroup.selectAll("rect.positive").data(@resolutedData.filter((d) => d.positive > 0))
    barsEnter = bars.enter().append("rect").attr("class", "bar positive")
    bars.exit().remove()

    allBars = bars.merge(barsEnter)
    allBars.attr("x", @xScale(0))
      .attr("width", (d) => @xScale(d.positive) - @xScale(0))

    @_applyBarHeights(allBars)

  _renderNegativeBars: ->
    bars = @barsGroup.selectAll("rect.negative").data(@resolutedData.filter((d) => d.negative > 0))
    barsEnter = bars.enter().append("rect").attr("class", "bar negative")
    bars.exit().remove()

    allBars = bars.merge(barsEnter)
    allBars.attr("x", (d) => @xScale(-d.negative))
      .attr("width", (d) => @xScale(0) - @xScale(-d.negative))
    @_applyBarHeights allBars

  _renderStops: ->
    stops = @stopsGroup.selectAll("g.stop").data(@stops)
    stopsEnter = stops.enter().append("g").attr("class", "stop")
    stopsEnter.append("text").attr("class", "label prefix points").attr("dy", "0.32em").attr("x", -@labelPadding)
    stopsEnter.append("text").attr("class", "label suffix above").attr("dy", "-0.32em")
    stopsEnter.append("text").attr("class", "label suffix below").attr("dy", "1em")
    stopsEnter.append("line").attr("class", "line stop").attr("x1", 0).attr("y1", 0).attr("y2", 0)

    stops.exit().remove()

    allStops = stops.merge(stopsEnter)
    allStops.attr("transform", (d) => "translate(#{[0, @yScale(d.points)]})")
    allStops.select(".line").attr("x2", @innerWidth).attr("stroke", (d) => @colorScale(d.above.grade))
    allStops.select(".label.points").text((d) => d.points)
    allStops.select(".label.above").attr("x", @labelPadding).text((d) => d.above.grade)
    allStops.select(".label.below").attr("x", @labelPadding).text((d) => d.below.grade)

  _renderStopBgs: ->
    bgs = @stopBackgroundsGroup.selectAll("g.background").data(@stops)
    bgsEnter = bgs.enter().append("g").attr("class", "background")
    bgsEnter.append("rect").attr("class", "background above").attr("x", 0)
    bgsEnter.append("rect").attr("class", "background below").attr("x", 0)
    bgs.exit().remove()

    allBgs = bgs.merge(bgsEnter)
    allBgs.classed("hovered", (d) => d.isHovered)
    allBgs.select(".background.above")
      .attr("fill", (d) => @colorScale(d.above.grade))
      .attr("width", @innerWidth)
      .attr("y", (d) =>
        if d.isDragged
          @yScale(d.above.max_points)
        else
          @yScale(d.points) - @collapsedBackgroundSize
      )
      .attr("height", (d) =>
        if d.isDragged
          Math.abs(@yScale(d.above.max_points) - @yScale(d.above.min_points))
        else
          @collapsedBackgroundSize
      )
    allBgs.select(".background.below")
      .attr("fill", (d) => @colorScale(d.below.grade))
      .attr("width", @innerWidth)
      .attr("y", (d) => @yScale(d.points))
      .attr("height", (d) =>
        if d.isDragged
          Math.abs(@yScale(d.below.max_points) - @yScale(d.below.min_points))
        else
          @collapsedBackgroundSize
      )

  _renderCursor: ->
    cursorData = if @hovering
      from = Math.floor(@mousePosition.points / @resolution) * @resolution
      to = from + @resolution - 1
      students = if activeDatum = @_findDatumAt(@mousePosition.points)
        activeDatum
      else
        {
          positive: 0,
          negative: 0
        }

      [{
        points: @mousePosition.points,
        range: {
          from: from,
          to: to
        },
        students: students
      }]
    else
      []

    cursor = @cursorGroup.selectAll(".cursor").data(cursorData)
    cursorEnter = cursor.enter().append("g").attr("class", "cursor")
    cursorEnter.append("line")
      .attr("class", "line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("y2", 0)
    cursorEnter.append("text")
      .attr("class", "label main")
      .attr("dy", "0.32em")
    cursorEnter.append("text")
      .attr("class", "label above")
      .attr("dy", "-0.82em")
    belowEnter = cursorEnter.append("text")
      .attr("class", "label below")
      .attr("dy", "1.5em")
    belowEnter.append("tspan").attr("class", "negative")
    belowEnter.append("tspan").attr("class", "spacer").text(" | ")
    belowEnter.append("tspan").attr("class", "positive")

    cursor.exit().remove()

    allCursors = cursor.merge(cursorEnter).attr("transform", (d) => "translate(#{[0, @yScale(d.points)]})")
    allCursors.select(".line")
      .attr("x2", @innerWidth)
    allCursors.select(".label.main")
      .attr("x", @innerWidth + @labelPadding)
      .text((d) => d.points)
    allCursors.select(".label.above")
      .attr("x", @innerWidth + @labelPadding)
      .text((d) => if Math.abs(d.range.from - d.range.to) > 1 then "#{d.range.from} - #{d.range.to}" else "")

    below = allCursors.select(".label.below")
      .attr("x", @innerWidth + @labelPadding)

    below.select(".negative").text((d) => d.students.negative)
    below.select(".positive").text((d) => d.students.positive)

  _renderDragLabels: ->
    dragLabelsData = []

    transformDatum = (d) =>
      {
        grade: d.grade
        students: @_studentsInRange(d)
        centerPoints: (d.min_points + d.max_points) / 2
      }

    @stops.filter((d) => d.isDragged).forEach((d) =>
      dragLabelsData.push(transformDatum(d.above))
      dragLabelsData.push(transformDatum(d.below))
    )

    dragLabels = @dragLabelsGroup.selectAll("g.drag-labels").data(dragLabelsData)
    dragLabelsEnter = dragLabels.enter().append("g").attr("class", "drag-labels")
    dragLabelsEnter.append("text").attr("class", "grade-label").attr("x", "0").attr("y", "-0.32em")
    dragLabelsEnter.append("text").attr("class", "students-label").attr("x", "0").attr("y", "1em")
    dragLabels.exit().remove()

    allLabels = dragLabels.merge(dragLabelsEnter)
    allLabels.attr("transform", (d) => "translate(#{[@innerWidth / 2, @yScale(d.centerPoints)]})")
    allLabels.select(".grade-label")
      .text((d) => d.grade)

    allLabels.select(".students-label")
      .text((d) => "Students: #{d.students}")

  _renderSignificantPoints: ->
    pointsData = if @options.showSignificantPoints
      @significantPoints
    else
      []

    points = @significantPointsGroup.selectAll(".point").data(pointsData)
    pointsEnter = points.enter().append("g").attr("class", "point")
    pointsEnter.append("text")
      .attr("dy", "-0.32em")
      .attr("class", "points-label")
    pointsEnter.append("text")
      .attr("dy", "1em")
      .attr("class", "name-label")
    pointsEnter.append("line")
      .attr("x1", 0)
      .attr("y1", 0)
      .attr("y2", 0)
      .attr("class", "line")
    points.exit().remove()

    allPoints = points.merge(pointsEnter)
      .attr("transform", (d) => "translate(#{[0, @yScale(d.points)]})")
    allPoints.select(".points-label")
      .attr("x", @innerWidth - @labelPadding)
      .text((d) => d.points)
    allPoints.select(".name-label")
      .attr("x", @innerWidth - @labelPadding)
      .text((d) => d.name)
    allPoints.select(".line").attr("x2", @innerWidth)

  _applyBarHeights: (bars) ->
    perPointsHeight = Math.abs(@yScale(0) - @yScale(1))
    bars
      .attr("y", (d) => @yScale(d.points + @resolution - 1) - (perPointsHeight - @bar.padding) / 2)
      .attr("height", (d) => perPointsHeight * @resolution - @bar.padding)

  # =================
  # = DOM Listeners =
  # =================

  _registerGlobalListeners: ->
    $(window).on "resize.grading-scale-editor", =>
      @_onWindowResized()

  _unregisterGlobalListeners: ->
    $(window).off "resize.grading-scale-editor"

  _registerChartListeners: ->
    @svg.on "mouseenter", =>
      @_onMouseEnteredSVG()

    @svg.on "mouseleave", =>
      @_onMouseLeaveSVG()

    @svg.on "mousemove", =>
      @_onMouseMoveSVG()

    @svg.on "mousedown", =>
      @_onMouseDownSVG()

    @svg.on "mouseup", =>
      @_onMouseUpSVG()

    @svgContainer.on "dblclick", (e) =>
      @_onDoubleClick()

    @resolutionSelect.on "change", =>
      @resolution = +@resolutionSelect.val()
      @_onResolutionChanged()

    @gridToggler.on "change", =>
      @_onGridToggled(@gridToggler.is(":checked"))

    @significantPointsToggler.on "change", =>
      @_onSignificantPointsToggled(@significantPointsToggler.is(":checked"))

    @submitButton.on "click", =>
      @_onSubmitClicked()

  # ==================
  # = Public Methods =
  # ==================

  destroy: ->
    @_unregisterGlobalListeners()

  updateStopPoints: (stop, points) ->
    @_updateStopPoints(stop, points)
    @_updateSubmitButton()
    @_render()

editors = []
$(document).on "ready page:load", ->
  for editor in editors
    editors.destroy()

  editors = []
  $elements = $(document).find("*[data-behavior=grading-scale-editor]")

  if $elements.length > 0
    $elements.each ->
      editors.push(new GradingScaleEditor($(@)))
