<!DOCTYPE html>
<!--

  DO NOT CHANGE IT. The file was automatically generated
  by syscmd(`json -a name version < package.json | tr -d "\n"')

  To make changes, grab the source at http://github.com/gromnitsky/weakspec,
  tweak it & compile a new version of 'options.html' file.
  
-->
<html lang='en'>
  <head>
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
    <div id='header'>
      <!-- Contents of weakspec_opts.header -->
	</div>

    <div id='controls'>
	<p>
      <button type='button' id='save'>Save All</button>
      <button type='button' id='reset'>All to Defaults</button>
	  <span id='debug'>
      <button type='button' id='clean'>Delete All Preferences</button>
      <button type='button' id='dump'>Dump to the Console</button>
	  </span>
	</p>  
    </div>

    <div id='preferences'>
      <!-- A Drawer draws here -->
      Wait for DOM rendering or (better) look into Error console.
    </div>
  </body>
</html>
