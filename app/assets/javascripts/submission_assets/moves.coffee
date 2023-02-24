# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# app/assets/javascripts/drag_and_drop.coffee

registerDragAndDrop = ->
  entryElements = document.querySelectorAll('.folder-entry, .file-entry');

  for entryElement in entryElements
    entryElement.addEventListener 'dragstart', dragStart
    entryElement.addEventListener 'dragenter', dragEnter
    entryElement.addEventListener 'dragover', dragOver
    entryElement.addEventListener 'dragleave', dragLeave
    entryElement.addEventListener 'drop', drop

document.addEventListener 'DOMContentLoaded', ->
  registerDragAndDrop()

$(document).on 'page:load', ->
  registerDragAndDrop()


dragStart = (event) ->
  console.log "dragStart function called"
  event.dataTransfer.setData 'text/plain', event.target.id
  console.log event

dragOver = (event) ->
  event.preventDefault()
  console.log "dragOver function called"
  targetElement = event.target.closest 'tr'
  if targetElement.classList.contains 'folder-entry'
    event.dataTransfer.dropEffect = 'move'
    targetElement.classList.add 'over'


dragEnter = (event) ->
  console.log "dragEnter function called"
  event.preventDefault()
  @classList.add 'over'

dragLeave = (event) ->
  console.log "dragLeave function called"
  @classList.remove 'over'

drop = (event) ->
  console.log "drop function calleddddddddddddddd"
  event.preventDefault()
  @classList.remove 'over'
  sourceId = event.dataTransfer.getData 'text/plain'
  sourceElement = document.getElementById sourceId
  targetElement = event.target.closest 'tr'
  targetPath = targetElement.id
  submissionId = sourceElement.id

  console.log targetElement

  # Check if the source element is a folder
  if targetElement.classList.contains 'folder-entry'
    if sourceElement.classList.contains 'file-entry'
      $.ajax
        type: 'POST'
        url: '/submission_assets/move'
        data:
          submission_asset_id: submissionId
          target_path: targetPath
        success: (data, textStatus, jqXHR) ->
          if data.redirect_url
            window.location.href = data.redirect_url
          else
            console.log "Folder moved successfully"
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "Error moving folder: #{errorThrown}"

# Get the element that is being dragged
draggableElement = document.querySelector '.draggable'

# Add the 'dragover' event listener to the window object
window.addEventListener 'dragover', (e) ->
# Check if the mouse is near the top or bottom of the window
  windowHeight = window.innerHeight
  mousePosition = e.clientY
  scrollDistance = 20

  if mousePosition < scrollDistance
# Scroll up by 20 pixels
    window.scrollBy 0, -20
  else if mousePosition > (windowHeight - scrollDistance)
# Scroll down by 20 pixels
    window.scrollBy 0, 20
