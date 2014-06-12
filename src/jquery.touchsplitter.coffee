###
# Touch Splitter JQuery was created by Cole Lawrence(github:ZombieHippie)
# This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
# Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
###
$.fn.touchSplit = (options = {}) ->
  if this[0].touchSplitter?
    throw "Cannot make a splitter here! '#{ this.selector }' already has a splitter!
            Use $('#{ this.selector }')[0].touchSplitter.destroy(<optional side to remove>) to remove it!"
  if this.children().length isnt 2 and this.children().length isnt 0
    throw "Cannot make a splitter here! Incorrect number of div children in '#{ this.selector }'"
  this[0].touchSplitter = new TouchSplitter(this, options)
class TouchSplitter
  constructor: (@element, options) ->
    @element.addClass 'TouchSplitter'
    # Support
    @support = {}

    # em size
    testEm = $ '<div class="test-em"></div>'
    testEm.appendTo @element
    barThick = testEm.width()
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

    if @firstMax and @secondMax
      console.log "Touch Splitter ERROR: cannot set max bounds of both first and second sections!"
      @secondMax = false

    # Docking
    if options.dock?
      if /both|left|top|first|right|bottom|second/i.test options.dock
        @docks = switch
          when /both/i.test options.dock then { first: true, second: true, name: "both" }
          when /left|top|first/i.test options.dock then { first: true, second: false, name: "first" }
          when /right|bottom|second/i.test options.dock then { first: false, second: true, name: "second" }
    if @docks then @element.addClass 'docks-' + @docks.name
    else @docks = { first: false, second: false, name: false }

    # Bar width
    if options.thickness?
      thickness = options.thickness
      units = "px"
      if typeof thickness is 'string'
        if match = thickness.match /^([\d\.]+)([a-zA-Z]+)$/
          thickness = match[1]
          units = match[2]
        thickness = parseFloat(thickness)
      if not thickness
        throw "Unable to parse given thickness: " + options.thickness
      else
        thickness = switch units
          when "px"
            barThick = thickness
          when "em"
            barThick *= thickness
          else
            throw "Invalid unit used in given thickness: " + units

    # Create Splitter bar div
    firstdiv = @element.find ">div:first"
    splitterHTML = "<div class=\"splitter-bar\">#{if (@docks.name and @docks.name.match(/first|second/)) then '<div></div>' else ''}</div>"
    if firstdiv.length is 0
      inners = @element.html()
      # Split it ourselves
      @element.html "
        <div></div>
        #{splitterHTML}
        <div></div>"
      @element.find(">div:first").html(inners)
    else
      firstdiv.after splitterHTML

    @barThicknessPx = barThick / 2
    @barThickness = .04  # half of the percent width
    @barPosition = 0.5
    @dragging = false
    @initMouse = 0
    @initBarPosition = 0

    @resize()
    @element.on('resize', @onResize)
    $(window).on('resize', @onResizeWindow)
    $(window).on('mouseup', @stopDragging)
    $(window).on 'mousemove', @drag
    @element.find('>.splitter-bar').on 'mousedown', @onMouseDown
    @element.find('>.splitter-bar').bind 'touchstart', @onTouchStart
    @element.on 'touchmove', @onTouchMove
    @element.on 'touchend', @onTouchEnd
    @element.on 'touchleave', @onTouchEnd
    @element.on 'touchcancel', @onTouchEnd

  destroy: (side) =>
    @element.off('resize')
    $(window).off('resize')
    $(window).off('mouseup')
    $(window).off 'mousemove'
    @element.find('>.splitter-bar').off 'mousedown'
    @element.find('>.splitter-bar').off 'touchstart'
    @element.off 'touchmove'
    @element.off 'touchend'
    @element.off 'touchleave'
    @element.off 'touchcancel'
    @element.find('>.splitter-bar').remove()
    @element.removeClass('TouchSplitter h-ts v-ts docks-first docks-second docks-both')
    if side?
      toRemove = switch side
        when 'left', 'top'
          '>div:first'
        when 'right', 'bottom'
          '>div:last'
        when 'both'
          '>div'
      @element.find(toRemove).remove()
    @element.children().css({width: "", height: ""})
    delete @element[0].touchSplitter

  setRatios: =>
    @splitDistance = if @horizontal then @element.width() else @element.height()
    for conv, val of {@firstMin, @firstMax, @secondMin, @secondMax}
      if val
        @[conv+'Ratio'] = val / @splitDistance
    @moveBar() # Conform to bounds

  toggleDock: =>
    @element.toggleClass 'docked'
    if @docked then @setDock false
    else @setDock @docks.name
  on: (eventName, fn) =>
    @element.on(eventName,fn)

  moveBar: (newX) =>
    cursorPos = @barPosition
    if newX?
      cursorPos = @initBarPosition + (newX - @initMouse) / @splitDistance # = range [0,1]
    cursorPos2 = 1 - cursorPos
    if @docks.name
      switch @docked
        when 'first'
          if cursorPos > @firstMinRatio / 2
            @setDock false
        when 'second'
          if cursorPos2 > @secondMinRatio / 2
            @setDock false
        else
          if @docks.first and cursorPos < @firstMinRatio / 2
            @setDock 'first'
          if @docks.second and cursorPos2 < @secondMinRatio / 2
            @setDock 'second'
    if not @docked
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

  setDock: (val, lastpos = @barPosition) =>
    @docked = val
    @barPosition = @lastPosition
    @lastPosition = lastpos
    @setPercentages()

  setPercentages: =>
    switch @docked
      when 'first'
        @barPosition = 0
      when 'second'
        @barPosition = 1
    pos = @barPosition
    firstCss = secondCss = ""
    if not @support.calc
      pos = @barThickness if pos < @barThickness
      pos = 1 - @barThickness if pos > 1 - @barThickness
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
    @isToggler = !! event.target.parentNode.className.match /\bsplitter-bar\b/
    @dragging = true
    @element.trigger "dragstart"

  drag: (event) =>
    return if not @dragging
    # Mozilla and Webkit handle the mousemove event differently 
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    @stopDragging() if whichM is 0 # And safari doesn't report buttons on mousemove at all so we have on mouseup
    client = if @horizontal then event.clientX else event.clientY
    @moveBar client

  stopDragging: (event) =>
    if @dragging
      @dragging = false
      @element.trigger "dragstop"
      if @isToggler
        setTimeout =>
          if (@barPosition - @initBarPosition) is 0
            @toggleDock()
        , 0


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
      @barThickness = @barThicknessPx / @splitDistance
      if @barThickness > 1
        @barThickness = 1
      @element.find('>.splitter-bar').css attr, @barThickness*200+'%'
    else
      @barThickness = 0
    @setPercentages()