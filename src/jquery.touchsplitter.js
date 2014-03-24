// Generated by CoffeeScript 1.7.1

/*
 * Touch Splitter JQuery was created by Cole Lawrence(github:ZombieHippie)
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
 * Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
 */
var TouchSplitter,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

$.fn.touchSplit = function(options) {
  if (options == null) {
    options = {};
  }
  if (this.children().length !== 2 && this.children().length !== 0) {
    throw "Cannot make a splitter here! Incorrect number of div children in " + this;
  }
  return new TouchSplitter(this, options);
};

TouchSplitter = (function() {
  function TouchSplitter(element, options) {
    var emWidth, firstdiv, splitterHTML, testCalc, testEm;
    this.element = element;
    this.resize = __bind(this.resize, this);
    this.onResize = __bind(this.onResize, this);
    this.onResizeWindow = __bind(this.onResizeWindow, this);
    this.getSecond = __bind(this.getSecond, this);
    this.getFirst = __bind(this.getFirst, this);
    this.stopDragging = __bind(this.stopDragging, this);
    this.drag = __bind(this.drag, this);
    this.startDragging = __bind(this.startDragging, this);
    this.onTouchEnd = __bind(this.onTouchEnd, this);
    this.onTouchMove = __bind(this.onTouchMove, this);
    this.onTouchStart = __bind(this.onTouchStart, this);
    this.onMouseDown = __bind(this.onMouseDown, this);
    this.setPercentages = __bind(this.setPercentages, this);
    this.moveBar = __bind(this.moveBar, this);
    this.on = __bind(this.on, this);
    this.toggleDock = __bind(this.toggleDock, this);
    this.setRatios = __bind(this.setRatios, this);
    this.splitDist = __bind(this.splitDist, this);
    this.element.addClass('TouchSplitter');
    this.support = {};
    testEm = $('<div class="test-em"></div>');
    testEm.appendTo(this.element);
    emWidth = testEm.width();
    testEm.remove();
    testCalc = $('<div class="test-calc"></div>');
    testCalc.appendTo(this.element);
    this.support.calc = false;
    testCalc.remove();
    if (options.orientation != null) {
      if (options.orientation === "vertical") {
        this.horizontal = false;
      } else if (options.orientation === "horizontal") {

      } else {
        console.log("Touch Splitter ERROR: orientation cannot be:'" + options.orientation + "' defaulted to 'horizontal'");
      }
    }
    if (this.horizontal !== false) {
      this.horizontal = true;
    }
    this.element.addClass(this.horizontal ? "h-ts" : "v-ts");
    this.firstMin = options.leftMin || options.topMin || options.firstMin || 0;
    this.firstMax = options.leftMax || options.topMax || options.firstMax || false;
    this.secondMin = options.rightMin || options.bottomMin || options.secondMin || 0;
    this.secondMax = options.rightMax || options.bottomMax || options.secondMax || false;
    this.isFirstBounded = !!this.firstMin || !!this.firstMax;
    this.isSecondBounded = !!this.secondMin || !!this.secondMax;
    if (this.firstMax && this.secondMax) {
      console.log("Touch Splitter ERROR: cannot set max bounds of both first and second sections!");
    }
    this.secondMax = 0;
    if (options.dock != null) {
      if (/left|right|top|bottom/.test(options.dock)) {
        this.dock = /left|top|first/.test(options.dock);
        this.dock = this.dock ? "first" : "second";
        this.element.addClass('docks-' + this.dock);
      }
    }
    if (this.dock == null) {
      this.dock = false;
    }
    firstdiv = this.element.find(">div:first");
    splitterHTML = "<div class=\"splitter-bar\">" + (this.dock ? '<div></div>' : '') + "</div>";
    if (firstdiv.length === 0) {
      this.element.append("<div></div> " + splitterHTML + " <div></div>");
    } else {
      firstdiv.after(splitterHTML);
    }
    if (this.dock) {
      this.element.find('>.splitter-bar>div').click(this.toggleDock);
    }
    this.barThicknessPx = emWidth / 2;
    this.barThickness = .04;
    this.barPosition = 0.5;
    this.dragging = false;
    this.initMouse = 0;
    this.initBarPosition = 0;
    this.onResize();
    this.element.on('resize', this.onResize);
    $(window).on('resize', this.onResizeWindow);
    $(window).on('mousemove', this.drag);
    this.element.find('>.splitter-bar').on('mousedown', this.onMouseDown);
    this.element.find('>.splitter-bar').bind('touchstart', this.onTouchStart);
    this.element.on('touchmove', this.onTouchMove);
    this.element.on('touchend', this.onTouchEnd);
    this.element.on('touchleave', this.onTouchEnd);
    this.element.on('touchcancel', this.onTouchEnd);
    this.setPercentages();
  }

  TouchSplitter.prototype.splitDist = function() {
    if (this.horizontal) {
      return this.element.width();
    }
    return this.element.height();
  };

  TouchSplitter.prototype.setRatios = function() {
    var conv, val, _ref;
    _ref = {
      firstMin: this.firstMin,
      firstMax: this.firstMax,
      secondMin: this.secondMin,
      secondMax: this.secondMax
    };
    for (conv in _ref) {
      val = _ref[conv];
      if (val) {
        this[conv + 'Ratio'] = val / this.splitDist();
      }
    }
    return this.moveBar(this.initMouse);
  };

  TouchSplitter.prototype.toggleDock = function(event) {
    if (event == null) {
      event = null;
    }
    this.element.toggleClass('docked');
    this.docked = !this.docked ? this.dock : false;
    return this.setPercentages();
  };

  TouchSplitter.prototype.on = function(eventName, fn) {
    return this.element.on(eventName, fn);
  };

  TouchSplitter.prototype.moveBar = function(newX) {
    var cursorPos, cursorPos2;
    cursorPos = this.initBarPosition + (newX - this.initMouse) / this.splitDist();
    cursorPos2 = 1 - cursorPos;
    switch (this.docked) {
      case 'first':
        if (cursorPos > this.firstMinRatio / 2) {
          this.docked = null;
        }
        break;
      case 'second':
        if (cursorPos2 > this.secondMinRatio / 2) {
          this.docked = null;
        }
        break;
      default:
        if (cursorPos2 < this.secondMinRatio / 2) {
          this.docked = 'second';
        }
        if (cursorPos < this.firstMinRatio / 2) {
          this.docked = 'first';
        }
    }
    this.barPosition = (function() {
      switch (false) {
        case !(this.firstMaxRatio && cursorPos > this.firstMaxRatio):
          return this.firstMaxRatio;
        case !(cursorPos < this.firstMinRatio):
          return this.firstMinRatio;
        case !(this.secondMaxRatio && cursorPos2 > this.secondMaxRatio):
          return 1 - this.secondMaxRatio;
        case !(cursorPos2 < this.secondMinRatio):
          return 1 - this.secondMinRatio;
        default:
          return cursorPos;
      }
    }).call(this);
    return this.setPercentages();
  };

  TouchSplitter.prototype.setPercentages = function() {
    var attr, first, firstCss, pos, second, secondCss, shave;
    pos = this.barPosition;
    switch (this.docked) {
      case 'first':
        pos = 0;
        break;
      case 'second':
        pos = 1;
    }
    firstCss = secondCss = "";
    if (!this.support.calc) {
      if (pos < this.barThickness) {
        pos = this.barThickness;
      }
      if (pos > 1 - this.barThickness) {
        pos = 1 - this.barThickness;
      }
      if (!this.docked) {
        this.barPosition = pos;
      }
      first = pos - this.barThickness;
      second = 1 - pos - this.barThickness;
      firstCss = "" + (100 * first - this.barThickness) + "%";
      secondCss = "" + (100 * second - this.barThickness) + "%";
    } else {
      shave = this.barThicknessPx;
      if (this.docked) {
        shave *= 2;
      }
      pos *= 100;
      firstCss = "calc(" + pos + "% - " + shave + "px)";
      secondCss = "calc(" + (100 - pos) + "% - " + shave + "px)";
    }
    attr = this.horizontal ? "width" : "height";
    this.getFirst().css(attr, firstCss);
    return this.getSecond().css(attr, secondCss);
  };

  TouchSplitter.prototype.onMouseDown = function(event) {
    event.preventDefault();
    this.initMouse = this.horizontal ? event.clientX : event.clientY;
    return this.startDragging(event);
  };

  TouchSplitter.prototype.onTouchStart = function(event) {
    var orig;
    orig = event.originalEvent;
    this.initMouse = this.horizontal ? orig.changedTouches[0].pageX : orig.changedTouches[0].pageY;
    return this.startDragging(event);
  };

  TouchSplitter.prototype.onTouchMove = function(event) {
    var orig, page;
    if (!this.dragging) {
      return;
    }
    event.preventDefault();
    orig = event.originalEvent;
    page = this.horizontal ? orig.changedTouches[0].pageX : orig.changedTouches[0].pageY;
    return this.moveBar(page);
  };

  TouchSplitter.prototype.onTouchEnd = function(event) {
    return this.stopDragging(event);
  };

  TouchSplitter.prototype.startDragging = function(event) {
    this.initBarPosition = this.barPosition;
    this.dragging = true;
    return this.element.trigger("dragstart");
  };

  TouchSplitter.prototype.drag = function(event) {
    var client, whichM;
    if (!this.dragging) {
      return;
    }
    whichM = typeof event.buttons !== 'undefined' ? event.buttons : event.which;
    if (whichM === 0) {
      this.stopDragging();
    }
    client = this.horizontal ? event.clientX : event.clientY;
    return this.moveBar(client);
  };

  TouchSplitter.prototype.stopDragging = function(event) {
    if (this.dragging) {
      this.dragging = false;
      return this.element.trigger("dragstop");
    }
  };

  TouchSplitter.prototype.getFirst = function() {
    return this.element.find('>div:first');
  };

  TouchSplitter.prototype.getSecond = function() {
    return this.element.find('>div:last');
  };

  TouchSplitter.prototype.onResizeWindow = function(event) {
    return this.resize();
  };

  TouchSplitter.prototype.onResize = function(event) {
    if (event != null) {
      event.stopPropagation();
      if (!$(event.target).is(this.element)) {
        return;
      }
    }
    return this.resize();
  };

  TouchSplitter.prototype.resize = function() {
    var attr;
    this.setRatios();
    attr = this.horizontal ? "width" : "height";
    if (!this.support.calc) {
      this.barThickness = this.barThicknessPx / this.splitDist();
      if (this.barThickness > 1) {
        this.barThickness = 1;
      }
      this.element.find('>.splitter-bar').css(attr, this.barThickness * 200 + '%');
    } else {
      this.barThickness = 0;
    }
    return this.setPercentages();
  };

  return TouchSplitter;

})();
