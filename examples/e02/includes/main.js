(function() {

	// A custom dive into widget.preferences without weakspec. Use
	// this with care & try not to clash values with your group
	// names.
	widget.preferences.prevAngle = 0
	
	function rotateElements() {
		console.log(ExtStorage.Get('Rotation', 'angle'))
		var angle = widget.preferences.prevAngle == 0 ? 180 : 0
		
		e = document.querySelectorAll("img")
		if (e.length == 0) {
			alert('No images found on the page.')
			return
		}
		
		for (var i = 0, len = e.length; i < len; ++i)
			e[i].style.OTransform = "rotate(" + angle + "deg)"

		widget.preferences.prevAngle = angle
	}
	
	window.addEventListener('DOMContentLoaded', function() {

		// Listen for messages from background.js
		opera.extension.onmessage = function(event) {
			switch (event.data) {
			case 'button:click':
				rotateElements()
				break
			default:
				console.error('e02: unknown message: ' + event.data)
				break
			}
		}
	}, false)

})()
