/* main */

window.addEventListener("load", function() {
	var UIItemProperties = {
		title: "My Button",
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
