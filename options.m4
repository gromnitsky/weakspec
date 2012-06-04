<!DOCTYPE html>
<html lang='en'>
  <head>
	<script src='options.weakspec.js'></script>
	
	<script>
include(`options.lib.js')
include(`options.js')
	</script>
	
	<style>
include(`style.css')
	</style>
  </head>
  <body>
	<div>
	  <p id="help">
		<a href="options.help.html" target="_blank">Help</a>
	  </p>
	  <p id="showall">
		<label>
		  <input type="checkbox">
		  Show all
		</label>
	  </p>
	  <p id="searchbox">
		<label> Quick find:
		  <input type="text">
		</label>
	  </p>
	</div>

	<div id='preferences'>
	  <!-- A Drawer draws here -->
	  Wait for DOM rendering...
	</div>
  </body>
</html>
