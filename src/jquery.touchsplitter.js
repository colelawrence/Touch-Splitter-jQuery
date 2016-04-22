// Generated by CoffeeScript 1.10.0

/*
 * Touch Splitter JQuery was created by Cole Lawrence(github:ZombieHippie)
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0
 * Unported License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
 */

(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (function(mod) {
    if (typeof exports === "object" && typeof module === "object") {
      return mod(require("jquery"));
    } else if (typeof define === "function" && define.amd) {
      return define(["jquery"], mod);
    } else {
      return mod(jQuery);
    }
  })(function(jQuery) {
    var $, TouchSplitter;
    $ = jQuery;
    $.fn.touchSplit = function(options) {
      if (options == null) {
        options = {};
      }
      if (this[0].touchSplitter != null) {
        throw "Cannot make a splitter here! '" + this.selector + "' already has a splitter! Use $('" + this.selector + "')[0].touchSplitter.destroy(<optional side to remove>) to remove it!";
      }
      if (this.children().length !== 2 && this.children().length !== 0) {
        throw "Cannot make a splitter here! Incorrect number of div children in '" + this.selector + "'";
      }
      return this[0].touchSplitter = new TouchSplitter(this, options);
    };
    return TouchSplitter = (function() {
      function TouchSplitter(element, options) {
        var barThick, firstdiv, inners, match, splitterHTML, testCalc, testEm, thickness, units;
        this.element = element;
        this.resize = bind(this.resize, this);
        this.onResize = bind(this.onResize, this);
        this.onResizeWindow = bind(this.onResizeWindow, this);
        this.getSecond = bind(this.getSecond, this);
        this.getFirst = bind(this.getFirst, this);
        this.stopDragging = bind(this.stopDragging, this);
        this.drag = bind(this.drag, this);
        this.startDragging = bind(this.startDragging, this);
        this.onTouchEnd = bind(this.onTouchEnd, this);
        this.onTouchMove = bind(this.onTouchMove, this);
        this.onTouchStart = bind(this.onTouchStart, this);
        this.onMouseDown = bind(this.onMouseDown, this);
        this.setPercentages = bind(this.setPercentages, this);
        this.setDock = bind(this.setDock, this);
        this.moveBar = bind(this.moveBar, this);
        this.on = bind(this.on, this);
        this.toggleDock = bind(this.toggleDock, this);
        this.setRatios = bind(this.setRatios, this);
        this.destroy = bind(this.destroy, this);
        this.element.addClass('TouchSplitter');
        this.support = {};
        testEm = $('<div class="test-em"></div>');
        testEm.appendTo(this.element);
        barThick = testEm.width();
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
        if (this.firstMax && this.secondMax) {
          console.log("Touch Splitter ERROR: cannot set max bounds of both first and second sections!");
          this.secondMax = false;
        }
        if (options.dock != null) {
          if (/both|left|top|first|right|bottom|second/i.test(options.dock)) {
            this.docks = (function() {
              switch (false) {
                case !/both/i.test(options.dock):
                  return {
                    first: true,
                    second: true,
                    name: "both"
                  };
                case !/left|top|first/i.test(options.dock):
                  return {
                    first: true,
                    second: false,
                    name: "first"
                  };
                case !/right|bottom|second/i.test(options.dock):
                  return {
                    first: false,
                    second: true,
                    name: "second"
                  };
              }
            })();
          }
        }
        if (this.docks) {
          this.element.addClass('docks-' + this.docks.name);
        } else {
          this.docks = {
            first: false,
            second: false,
            name: false
          };
        }
        if (options.thickness != null) {
          thickness = options.thickness;
          units = "px";
          if (typeof thickness === 'string') {
            if (match = thickness.match(/^([\d\.]+)([a-zA-Z]+)$/)) {
              thickness = match[1];
              units = match[2];
            }
            thickness = parseFloat(thickness);
          }
          if (!thickness) {
            throw "Unable to parse given thickness: " + options.thickness;
          } else {
            thickness = (function() {
              switch (units) {
                case "px":
                  return barThick = thickness;
                case "em":
                  return barThick *= thickness;
                default:
                  throw "Invalid unit used in given thickness: " + units;
              }
            })();
          }
        }
        this.startPosition = options.startPosition === 0 ? 0 : options.startPosition ? options.startPosition : 0.5;
        if (this.startPosition < 0 || this.startPosition > 1) {
          throw "Bar starting position out of bounds. Please enter a value larger between 0 and 1";
        }
        firstdiv = this.element.find(">div:first");
        splitterHTML = "<div class=\"splitter-bar\">" + (this.docks.name && this.docks.name.match(/first|second/) ? '<div></div>' : '') + "</div>";
        if (firstdiv.length === 0) {
          inners = this.element.html();
          this.element.html("<div></div> " + splitterHTML + " <div></div>");
          this.element.find(">div:first").html(inners);
        } else {
          firstdiv.after(splitterHTML);
        }
        this.barThicknessPx = barThick / 2;
        this.barThickness = .04;
        this.barPosition = this.startPosition;
        this.dragging = false;
        this.initMouse = 0;
        this.initBarPosition = 0;
        this.resize();
        this.element.on('resize', this.onResize);
        $(window).on('resize', this.onResizeWindow);
        $(window).on('mouseup', this.stopDragging);
        $(window).on('mousemove', this.drag);
        this.element.find('>.splitter-bar').on('mousedown', this.onMouseDown);
        this.element.find('>.splitter-bar').bind('touchstart', this.onTouchStart);
        this.element.on('touchmove', this.onTouchMove);
        this.element.on('touchend', this.onTouchEnd);
        this.element.on('touchleave', this.onTouchEnd);
        this.element.on('touchcancel', this.onTouchEnd);
      }

      TouchSplitter.prototype.destroy = function(side) {
        var toRemove;
        this.element.off('resize');
        $(window).off('resize');
        $(window).off('mouseup');
        $(window).off('mousemove');
        this.element.find('>.splitter-bar').off('mousedown');
        this.element.find('>.splitter-bar').off('touchstart');
        this.element.off('touchmove');
        this.element.off('touchend');
        this.element.off('touchleave');
        this.element.off('touchcancel');
        this.element.find('>.splitter-bar').remove();
        this.element.removeClass('TouchSplitter h-ts v-ts docks-first docks-second docks-both');
        if (side != null) {
          toRemove = (function() {
            switch (side) {
              case 'left':
              case 'top':
                return '>div:first';
              case 'right':
              case 'bottom':
                return '>div:last';
              case 'both':
                return '>div';
            }
          })();
          this.element.find(toRemove).remove();
        }
        this.element.children().css({
          width: "",
          height: ""
        });
        return delete this.element[0].touchSplitter;
      };

      TouchSplitter.prototype.setRatios = function() {
        var conv, ref, val;
        this.splitDistance = this.horizontal ? this.element.width() : this.element.height();
        ref = {
          firstMin: this.firstMin,
          firstMax: this.firstMax,
          secondMin: this.secondMin,
          secondMax: this.secondMax
        };
        for (conv in ref) {
          val = ref[conv];
          if (val) {
            this[conv + 'Ratio'] = val / this.splitDistance;
          }
        }
        return this.moveBar();
      };

      TouchSplitter.prototype.toggleDock = function() {
        this.element.toggleClass('docked');
        if (this.docked) {
          return this.setDock(false);
        } else {
          return this.setDock(this.docks.name);
        }
      };

      TouchSplitter.prototype.on = function(eventName, fn) {
        return this.element.on(eventName, fn);
      };

      TouchSplitter.prototype.moveBar = function(newX) {
        var cursorPos, cursorPos2;
        cursorPos = this.barPosition;
        if (newX != null) {
          cursorPos = this.initBarPosition + (newX - this.initMouse) / this.splitDistance;
        }
        cursorPos2 = 1 - cursorPos;
        if (this.docks.name) {
          switch (this.docked) {
            case 'first':
              if (cursorPos > this.firstMinRatio / 2) {
                this.setDock(false);
              }
              break;
            case 'second':
              if (cursorPos2 > this.secondMinRatio / 2) {
                this.setDock(false);
              }
              break;
            default:
              if (this.docks.first && cursorPos < this.firstMinRatio / 2) {
                this.setDock('first');
              }
              if (this.docks.second && cursorPos2 < this.secondMinRatio / 2) {
                this.setDock('second');
              }
          }
        }
        if (!this.docked) {
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
        }
      };

      TouchSplitter.prototype.setDock = function(val, lastpos) {
        if (lastpos == null) {
          lastpos = this.barPosition;
        }
        this.docked = val;
        this.barPosition = this.lastPosition;
        this.lastPosition = lastpos;
        return this.setPercentages();
      };

      TouchSplitter.prototype.setPercentages = function() {
        var attr, first, firstCss, pos, second, secondCss, shave;
        switch (this.docked) {
          case 'first':
            this.barPosition = 0;
            break;
          case 'second':
            this.barPosition = 1;
        }
        pos = this.barPosition;
        firstCss = secondCss = "";
        if (!this.support.calc) {
          if (pos < this.barThickness) {
            pos = this.barThickness;
          }
          if (pos > 1 - this.barThickness) {
            pos = 1 - this.barThickness;
          }
          first = pos - this.barThickness;
          second = 1 - pos - this.barThickness;
          firstCss = (100 * first - this.barThickness) + "%";
          secondCss = (100 * second - this.barThickness) + "%";
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
        this.isToggler = !!event.target.parentNode.className.match(/\bsplitter-bar\b/);
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
          this.element.trigger("dragstop");
          if (this.isToggler) {
            return setTimeout((function(_this) {
              return function() {
                if ((_this.barPosition - _this.initBarPosition) === 0) {
                  return _this.toggleDock();
                }
              };
            })(this), 0);
          }
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
          this.barThickness = this.barThicknessPx / this.splitDistance;
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
  });

}).call(this);
