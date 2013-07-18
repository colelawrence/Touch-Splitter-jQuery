###
# Touch Splitter JQuery was created by Cole Lawrence(github:ZombieHippie)
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
###
$.fn.horizontalSplit = () ->
  if this.children().length isnt 2 and this.children().length isnt 0
    throw "Cannot make a splitter here! Incorrect number of div children in "+this
  this.addClass('TouchSplitter hTS')
  new TouchSplitter(this, true)
$.fn.verticalSplit = () ->
  childs = this.children().length
  if childs isnt 2 and childs isnt 0
    throw "Cannot make a splitter here! Incorrect number of div children in "+this
  this.addClass('TouchSplitter vTS')
  new TouchSplitter(this, false)

class TouchSplitter
  constructor: (@element, @horizontal) ->
    # Create Splitter bar div
    firstdiv = @element.find ">div:first"
    if firstdiv.length is 0
      # Split it ourselves
      @element.append "
        <div></div>
        <div class=\"splitter-bar\"></div>
        <div></div>"
    else
      firstdiv.after "<div class=\"splitter-bar\"></div>"
    @barThicknessPx = 10
    @barThickness = .04  # This represents half of the percent width
    @barPosition = 0.5
    @barPositionMin = @min / @element.width()
    @barPositionMax = @max / @element.width()
    @dragging = false
    @docked = false
    @initMouse = 0
    @initBarPosition = 0

    @onResize()
    @element.on('resize', @onResize)
    @setupMouseEvents()
    @setPercentages()

  splitDist: =>
    return @element.width() if @horizontal
    return @element.height()

  setPercentages: =>
    first = @barPosition - @barThickness
    second = 1 - @barPosition - @barThickness
    console.log first + " " + @barPosition
    attr = if @horizontal then "width" else "height"
    @getFirst().css attr, (100*first) + "%"
    @getSecond().css attr, (100*second) + "%"
    e = jQuery.Event( "resize", { horizontal:@horizontal, } );
    @getFirst().trigger("resize")
    @getSecond().trigger("resize")
  setupMouseEvents: =>
    $(window).on 'mousemove', @drag
    @element.find('.splitter-bar').on 'mousedown', @startDragging
    @element.find('.splitter-bar').on 'touchstart', @touchStart
    @element.find('.splitter-bar').on 'touchmove', @touchMove

  startDragging: (event) =>
    @initMouse = if @horizontal then event.clientX else event.clientY
    @dragging = true
    @initBarPosition = @barPosition
    event.preventDefault()

  drag: (event) =>
    return if not @dragging
    # Mozilla and Webkit handle the mousemove event differently 
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    @stopDragging() if whichM is 0
    client = if @horizontal then event.clientX else event.clientY
    @barPosition = @initBarPosition + (client-@initMouse)/@splitDist()
    @setPercentages()

  stopDragging: (event) =>
    @dragging = false

  touchStart: (event) =>
    orig = event.originalEvent;
    @initMouse = if @horizontal then orig.changedTouches[0].pageX else orig.changedTouches[0].pageY
    @initBarPosition = @barPosition

  touchMove: (event) =>
    event.preventDefault()
    orig = event.originalEvent
    page = if @horizontal then orig.changedTouches[0].pageX else orig.changedTouches[0].pageY
    @barPosition = @initBarPosition + (page-@initMouse)/@splitDist 

  getFirst: =>
    @element.find('>div:first')
  getSecond: =>
    @element.find('>div:last')

  onResize:(event=null) =>
    if event isnt null
      event.stopPropagation()
      return if not $(event.target).is @element
    @barThickness = @barThicknessPx/@splitDist()
    attr = if @horizontal then "width" else "height"
    @element.find('>.splitter-bar').css attr, @barThickness*200+'%'
    @barPositionMin = @min / @splitDist
    @barPositionMax = @max / @splitDist
    @setPercentages()