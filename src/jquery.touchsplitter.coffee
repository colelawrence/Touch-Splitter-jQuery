class TouchSplitter
  constructor: (@id, @min, init, @max) ->
    @barWidth = 5        # This represents half of the percent width
    @barPosition = 0.3
    @barPositionMin = @min / $('#'+@id).width()
    @barPositionMax = @max / $('#'+@id).width()
    @lastOpenPos = init
    @dragging = false
    @docked = false
    @initMouseX = 0
    @initBarPosition = 0
    @splitWidth = 0
    @fullsreen = false

    @onResize()
    $(window).on('resize', @onResize)
    $('#'+@id).addClass 'hsplit'
    @setupMouseEvents()

  setupMouseEvents: =>
    $('#'+@id+' #splitter-bar').on 'mousedown', @startDragging
    $('#'+@id).on 'mouseleave', @stopDragging
    $('#'+@id).on 'mousemove', @drag
    $('#'+@id).on 'click', '#splitter-bar #toggle', @toggleDock
    $('#'+@id+' #splitter-bar').on 'touchstart', @touchStart
    $('#'+@id+' #splitter-bar').on 'touchmove', @touchMove

  toggleDock: =>
    if @docked
      @undock()
    else 
      @dock()
    @dragging = false

  dock: =>
    @lastOpenPos = @barPosition
    @barPosition = 0
    @getLeft().hide()
    @docked=true
    @update()

  undock: =>
    @barPosition = @lastOpenPos
    @getLeft().show()
    @docked=false
    @update()
    $(window).resize()

  startDragging: (event) =>
    @dragging = true
    @initMouseX = event.clientX
    @initBarPosition = @barPosition
    event.preventDefault()

  drag: (event) =>
    return if not @dragging
    whichM = if typeof event.buttons isnt 'undefined' then event.buttons else event.which
    @stopDragging() if whichM is 0
    @setBarPosition @initBarPosition + (event.clientX-@initMouseX)/@splitWidth 

  stopDragging: (event) =>
    @dragging = false
    $('#file-manager').resize()

  touchStart: (event) =>
    orig = event.originalEvent;
    @initMouseX = orig.changedTouches[0].pageX
    @initBarPosition = @barPosition

  touchMove: (event) =>
    event.preventDefault()
    orig = event.originalEvent
    @setBarPosition @initBarPosition + (orig.changedTouches[0].pageX-@initMouseX)/@splitWidth 

  getLeft: ->
    $('#'+@id+'>div:first')
  getRight: ->
    $('#'+@id+'>div:last')

  setBarPosition: (pos) =>
    if @docked
      if pos > @barPositionMin/2
        @lastOpenPos = @barPositionMin
        return @undock()
    else
      if pos < @barPositionMin/2
        return @dock()

    pos = @barPositionMin if pos < @barPositionMin and not @docked
    pos = @barPositionMax if pos > @barPositionMax
    pos = 0 if pos < 0 or @docked
    @barPosition = pos
    @update()

  toggleFullscreen: =>
    me = $('#'+@id)
    if not @fullscreen
      me.addClass('hsplit-fullscreen')
      @getRight().append '<div class="hsplit-toolbar">'+Touch   '<img onclick="$(\'#fsave a\').click()" src="/static/editorLib/hippiesplitter/link-save.png" alt="Save File">'+
        '<img onclick="$(\'#fsnapshot a\').click()" src="/static/editorLib/hippiesplitter/link-snapshot.png" alt="Snapshot">'+
        '<img onclick="$(\'#selected-app .menu a:last\').click()" src="/static/editorLib/hippiesplitter/link-settings.png" alt="Settings"></div>'
    else
      me.removeClass('hsplit-fullscreen')
      @getRight().find('.hsplit-toolbar').remove()

    @fullscreen = !@fullscreen
    $(window).resize()
    return @fullscreen

  onResize: =>
    @splitWidth = $('#'+@id).width()
    @barWidth = 12/@splitWidth * 100 # bar width is 24px
    $('#'+@id+' #splitter-bar').width @barWidth*2+'%'
    @barPositionMin = @min / @splitWidth
    @barPositionMax = @max / @splitWidth
    @update()

  update: =>
    percLeft = @barPosition * 100
    percRight = 100 - percLeft
    percRight -= @barWidth*2
    @getLeft().width percLeft+'%'
    @getRight().width percRight+'%'
    $('#'+@id+'>#splitter-bar').css 'left':percLeft+'%'