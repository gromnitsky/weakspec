(function() {
window.addEventListener('DOMContentLoaded', function() {

	// Listen for messages from background.js
	opera.extension.onmessage = function(event) {
		switch (event.data) {
		case 'button:click':
			alert('hi')
			break
		default:
			console.error('e01: unknown message: ' + event.data)
			break
		}
	}
}, false)

})()
