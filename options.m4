<!DOCTYPE html>
<html lang='en'>
  <head>
    <title>Weakspec</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
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
	<div id='menu'>
	  <p>
		<a href="options.help.html" target="_blank">Help</a>
	  </p>
	</div>

	<div id='controls'>
	  <button type='button' id='save'>Save All</button>
	  <button type='button' id='reset'>Reset All to Defaults</button>
	  <button type='button' id='clean'>Delete All Preferences</button>
	  <button type='button' id='dump'>Dump Values to the Console</button>
	</div>

	<div id='preferences'>
	  <!-- A Drawer draws here -->
	  Wait for DOM rendering...
	</div>
  </body>
</html>
