window.addEventListener("load", function() {
	new WeakSpecPopulator('options.weakspec.js')
	
	var UIItemProperties = {
		title: "Rotate!",
//		icon: "icons/18.png",
		onclick: function() {
			// a msg to the current tab
			var tab = opera.extension.tabs.getFocused()
			if (tab) tab.postMessage('button:click')
		}
	}

	// add a button
	var b = opera.contexts.toolbar.createItem(UIItemProperties)
	opera.contexts.toolbar.addItem(b);
}, false)
