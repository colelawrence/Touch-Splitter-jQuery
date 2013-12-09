# Touch-Splitter-jQuery
*A high performance splitter system with events, compatible with touch screens*


***Demo!***
http://zombiehippie.com/ide/



## Features:
* Use your finger to move the splitter left and right / up and down
* Fluid resizing using percentages
* Fast and JSLint proof Javascript

## Simple Setup

Simply add the files to your document
```html
<link href="src/touchsplitter.css" rel="stylesheet"/>
<script src="src/jquery.touchsplitter.js"></script>
```
Then use an element with two divs inside it, to split it using the `$('#elem').split()` function.

### Options:
`$('#elem').split(options = {})`

#### Setup
* `orientation`: "horizontal" or "vertical"

#### Boundaries
* `firstMax`: maximum size of left or top side
* `firstMin`: minimum size of left or top side
* `secondMax`: maximum size of right or bottom side
* `secondMin`: minimum size of right or bottom side

Example values: `400px`, `20%`
