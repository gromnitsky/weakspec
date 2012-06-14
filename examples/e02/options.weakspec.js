var weakspec = {
	"Rotation" : {
		"angle" : {
			"type" : "number",
			"default" : 180,
			"desc" : "Angle in degrees",
			"range" : [-360, 360]
		},
		"domquery" : {
			"type" : "string",
			"default" : "img",
			"desc" : "CSS selector",
			"help" : "... for document.querySelectorAll()",
			"allowEmpty" : false,
			"validationRegexp" : null
		}
	}
}

