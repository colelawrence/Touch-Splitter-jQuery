###
# Touch Splitter JQuery was created by Cole Lawrence(github:ZombieHippie)
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
###
$.fn.touchSplit = (options = {}) ->
  if this.children().length isnt 2 and this.children().length isnt 0
    throw "Cannot make a splitter here! Incorrect number of div children in "+this
  new TouchSplitter(this, options)
class TouchSplitter
  constructor: (@element, options) ->
    # Orientation
    if options.orientation?
      if options.orientation is "vertical"
        @horizontal = false
      else if options.orientation is "horizontal"
        @horizontal = true
      else
        console.log "Touch Splitter ERROR: orientation cannot be:'" + options.orientation + "' defaulted to 'horizontal'"
    else
      @horizontal = true
    @element.addClass('TouchSplitter '+ if @horizontal then "hTS" else "vTS")

    @firstMin = options.leftMin || options.topMin || options.firstMin || 0
    @firstMax = options.leftMax || options.topMax || options.firstMax || 0
    @secondMin = options.rightMin || options.bottomMin || options.secondMin || 0
    @SecondMax = options.rightMax || options.bottomMax || options.secondMax || 0
    @isFirstBounded = if @firstMin is 0 and @firstMax is 0 then false else true
    @isSecondBounded = if @secondMin is 0 and @secondMax is 0 then false else true

    if @firstMax and @secondMax
      console.log "Touch Splitter ERROR: cannot set max bounds all sections!"
    @secondMax = 0

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
    $(window).on('resize', @onResizeWindow)
    $(window).on 'mousemove', @drag
    @element.find('>.splitter-bar').on 'mousedown', @onMouseDown
    @element.find('>.splitter-bar').bind 'touchstart', @onTouchStart
    @element.on 'touchmove', @onTouchMove
    @element.on 'touchend', @onTouchEnd
    @element.on 'touchleave', @onTouchEnd
    @element.on 'touchcancel', @onTouchEnd
    @setPercentages()

  splitDist: =>
    return @element.width() if @horizontal
    return @element.height()

  on: (eventName, fn) =>
    @element.on(eventName,fn)

  moveBar: (page) =>
    @barPosition = @initBarPosition + (page-@initMouse)/@splitDist()
    @setPercentages()

  setPercentages: =>
    @barPosition = @barThickness if @barPosition < @barThickness
    @barPosition = 1 - @barThickness if @barPosition > 1 - @barThickness
    first = @barPosition - @barThickness
    second = 1 - @barPosition - @barThickness
    attr = if @horizontal then "width" else "height"
    @getFirst().css attr, (100*first) + "%"
    @getSecond().css attr, (100*second) + "%"
    # Will want to use a siblings('.TouchSplitter') selector
    e = jQuery.Event( "resize", { horizontal:@horizontal } );
    @getFirst().trigger("resize")
    @getSecond().trigger("resize")

  onMouseDown: (event) =>
    event.preventDefault()
    @initMouse = if @horizontal then event.clientX else event.clientY
    @startDragging(event)

  onTouchStart: (event) =>
    orig = event.originalEvent;
    @initMouse = if @horizontal then orig.changedTouches[0].pageX else orig.changedTouches[0].pageY
    @startDragging(event)

  onTouchMove: (event) =>
    return if not @dragging
    event.preventDefault()
    orig = event.originalEvent
    page = if @horizontal then orig.changedTouches[0].pageX else orig.changedTouches[0].pageY
    @moveBar page

  onTouchEnd: (event) =>
    @stopDragging(event)

  startDragging: (event) =>
    @initBarPosition = @barPosition
    @dragging = true
    @element.trigger "dragstart"

  drag: (event) =>
    return if not @dragging
    # Mozilla and Webkit handle the mousemove event differently 
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    @stopDragging() if whichM is 0
    client = if @horizontal then event.clientX else event.clientY
    @barPosition = @initBarPosition + (client-@initMouse)/@splitDist()
    @setPercentages()

  stopDragging: (event) =>
    if @dragging
      @dragging = false
      @element.trigger "dragstop"


  getFirst: =>
    @element.find('>div:first')
  getSecond: =>
    @element.find('>div:last')

  onResizeWindow:(event=null) =>
    @resize()

  onResize:(event=null) =>
    if event isnt null
      event.stopPropagation()
      return if not $(event.target).is @element
    @resize()

  resize: =>
    @barThickness = @barThicknessPx/@splitDist()
    if @barThickness > 1
      @barThickness = 1
    attr = if @horizontal then "width" else "height"
    @element.find('>.splitter-bar').css attr, @barThickness*200+'%'
    @barPositionMin = @min / @splitDist
    @barPositionMax = @max / @splitDist
    @setPercentages()