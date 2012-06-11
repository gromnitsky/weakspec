<!DOCTYPE html>
<html lang='en'>
  <head>
    <meta name="generator" content="syscmd(`json -a name version < package.json | tr -d "\n"')" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Weakspec</title>
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
	<p>
      <button type='button' id='save'>Save All</button>
      <button type='button' id='reset'>Reset All to Defaults</button>
      <button type='button' id='clean'>Delete All Preferences</button>
      <button type='button' id='dump'>Dump Values to the Console</button>
	</p>  
    </div>

    <div id='preferences'>
      <!-- A Drawer draws here -->
      Wait for DOM rendering or (better) look into Error console.
    </div>
  </body>
</html>
