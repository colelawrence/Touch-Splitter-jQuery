Touch-Splitter-jQuery
=====================

A high performance html splitter compatible with touch events

![Touch Splitter](http://i.imgur.com/QkMajJa.png)

##**Demos**

####[Basic Demo Page](http://zombiehippie.github.io/Touch-Splitter-jQuery/)
This is our basic page that is pictured above. You can see the source in the [index.html](/index.html) file.

####[Quick Test CoffeeScript](http://zombiehippie.github.io/Quick-Test-CoffeeScript/)
Basic ide that uses two different splitters, one vertical splitter, then a horizontal splitter that divides the source from the compiled.

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
