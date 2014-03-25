Touch-Splitter-jQuery
=====================

A high performance html splitter compatible with touch events

![Touch Splitter](http://i.imgur.com/QkMajJa.png)

##Install via npm

```npm install touch-splitter-jquery```

You can then use the compiled javascript and css in your client resources.

 * `./node_modules/touch-splitter-jquery/src/jquery.touchsplitter.js`
 * `./node_modules/touch-splitter-jquery/src/touchsplitter.css`


##**Demos**

####[Basic Demo Page](http://zombiehippie.github.io/Touch-Splitter-jQuery/)
This is our basic page that is pictured above. You can see the source in the [index.html](/index.html) file.

####[Quick Test CoffeeScript](http://zombiehippie.github.io/Quick-Test-CoffeeScript/)
Basic ide that uses two different splitters, one vertical splitter, then a horizontal splitter that divides the source from the compiled javascript.

## Example Setup
It is highly recommended that your splitter container has a relative, absolute, or fixed `position`
```html
  <script src="http://code.jquery.com/jquery-1.10.1.min.js"></script>
	<script src="src/jquery.touchsplitter.js"></script>
	<h1>Basic Demo</h1>
	<div class="split-me-container">
		<div class="split-me">
			<div> Left Side </div>
			<div> Right Side </div>
		</div>
	</div>
	<script>
		touchSplitter1 = $('.split-me').touchSplit({leftMax:300, leftMin:100, dock:"left"})
		touchSplitter1.getFirst().touchSplit({orientation:"vertical"})
	</script>
```

## Teardown
To teardown a touch splitter you can use any of the following methods

```javascript
var splitted = $('.split-me')

// Destroy splitter without removing either first or second element
splitted.touchSplitter.destroy();

// Destroy splitter and remove top or left element
splitted.touchSplitter.destroy('first');

// Destroy splitter and remove bottom or right element
splitted.touchSplitter.destroy('second');

// Destroy splitter and remove all elements
splitted.touchSplitter.destroy('both');

(typeof splitted.touchSplitter === 'undefined') // true
```