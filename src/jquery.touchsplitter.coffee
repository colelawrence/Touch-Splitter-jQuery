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
    @element.addClass 'TouchSplitter'
    # Support
    @support = {}

    # em size
    testEm = $ '<div class="test-em"></div>'
    testEm.appendTo @element
    emWidth = testEm.width()
    testEm.remove()

    # calc
    testCalc = $ '<div class="test-calc"></div>'
    testCalc.appendTo @element
    @support.calc = false #20 is parseInt testCalc.width()
    testCalc.remove()

    # Orientation
    if options.orientation?
      if options.orientation is "vertical"
        @horizontal = false
      else if options.orientation is "horizontal"
      else
        console.log "Touch Splitter ERROR: orientation cannot be:'" + options.orientation + "' defaulted to 'horizontal'"

    @horizontal = true if @horizontal isnt false
    @element.addClass(if @horizontal then "h-ts" else "v-ts")

    # Minimums and maximums
    @firstMin = options.leftMin || options.topMin || options.firstMin || 0
    @firstMax = options.leftMax || options.topMax || options.firstMax || false
    @secondMin = options.rightMin || options.bottomMin || options.secondMin || 0
    @secondMax = options.rightMax || options.bottomMax || options.secondMax || false
    @isFirstBounded = !!@firstMin or !!@firstMax
    @isSecondBounded = !!@secondMin or !!@secondMax

    if @firstMax and @secondMax
      console.log "Touch Splitter ERROR: cannot set max bounds of both first and second sections!"
    @secondMax = 0

    # Docking
    if options.dock?
      if /left|right|top|bottom/.test options.dock
        @dock = /left|top|first/.test options.dock
        @dock = if @dock then "first" else "second"
        @element.addClass 'docks-' + @dock
    @dock ?= false

    # Create Splitter bar div
    firstdiv = @element.find ">div:first"
    splitterHTML = "<div class=\"splitter-bar\">#{if @dock then '<div></div>' else ''}</div>"
    if firstdiv.length is 0
      # Split it ourselves
      @element.append "
        <div></div>
        #{splitterHTML}
        <div></div>"
    else
      firstdiv.after splitterHTML

    if @dock
      @element.find('>.splitter-bar>div').click @toggleDock

    @barThicknessPx = emWidth / 2
    @barThickness = .04  # half of the percent width
    @barPosition = 0.5
    @dragging = false
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
  setRatios: =>
    for conv, val of {@firstMin, @firstMax, @secondMin, @secondMax}
      if val
        @[conv+'Ratio'] = val / @splitDist()
    @moveBar(@initMouse) # Conform to bounds

  toggleDock:(event = null) =>
    @element.toggleClass 'docked'
    @docked = if not @docked then @dock else false
    @setPercentages()
  on: (eventName, fn) =>
    @element.on(eventName,fn)

  moveBar: (newX) =>
    cursorPos = @initBarPosition + (newX - @initMouse) / @splitDist() # = range [0,1]
    cursorPos2 = 1 - cursorPos
    switch @docked
      when 'first'
        if cursorPos > @firstMinRatio / 2
          @docked = null
      when 'second'
        if cursorPos2 > @secondMinRatio / 2
          @docked = null
      else
        if cursorPos2 < @secondMinRatio / 2
          @docked = 'second'
        if cursorPos < @firstMinRatio / 2
          @docked = 'first'
    @barPosition = switch
      when @firstMaxRatio and cursorPos > @firstMaxRatio
        @firstMaxRatio
      when cursorPos < @firstMinRatio
        @firstMinRatio
      when @secondMaxRatio and cursorPos2 > @secondMaxRatio
        1 - @secondMaxRatio
      when cursorPos2 < @secondMinRatio
        1 - @secondMinRatio
      else
        cursorPos
    @setPercentages()

  setPercentages: =>
    pos = @barPosition
    switch @docked
      when 'first'
        pos = 0
      when 'second'
        pos = 1
    firstCss = secondCss = ""
    if not @support.calc
      pos = @barThickness if pos < @barThickness
      pos = 1 - @barThickness if pos > 1 - @barThickness
      if not @docked
        @barPosition = pos
      first = pos - @barThickness
      second = 1 - pos - @barThickness
      firstCss = "#{ 100*first - @barThickness}%"
      secondCss = "#{ 100*second - @barThickness}%"
    else
      shave = @barThicknessPx
      shave *= 2 if @docked
      pos *= 100
      firstCss = "calc(#{ pos }% - #{ shave }px)"
      secondCss = "calc(#{ 100-pos }% - #{ shave }px)"

    attr = if @horizontal then "width" else "height"
    @getFirst().css attr, firstCss
    @getSecond().css attr, secondCss
    # Will want to use a siblings('.TouchSplitter') selector
    #e = jQuery.Event( "resize", { horizontal:@horizontal } );
    #@getFirst().trigger("resize")
    #@getSecond().trigger("resize")

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
    @moveBar client

  stopDragging: (event) =>
    if @dragging
      @dragging = false
      @element.trigger "dragstop"

  getFirst: =>
    @element.find('>div:first')
  getSecond: =>
    @element.find('>div:last')

  onResizeWindow:(event) =>
    @resize()

  onResize:(event) =>
    if event?
      event.stopPropagation()
      return if not $(event.target).is @element
    @resize()

  resize: =>
    @setRatios()
    attr = if @horizontal then "width" else "height"
    if not @support.calc
      @barThickness = @barThicknessPx/@splitDist()
      if @barThickness > 1
        @barThickness = 1
      @element.find('>.splitter-bar').css attr, @barThickness*200+'%'
    else
      @barThickness = 0
    @setPercentages()