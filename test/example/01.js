var weakspec = {
	"Group 1" : {
		"opt1" : {
			"desc" : "Option #1 in group #1",
			"help" : "A help string for an options #1 in group 1",
			"type" : "string",
			"default" : "ua",
			"validationRegexp" : "^[a-z]{2}$",
			"validationCallback" : null,
			"allowEmpty" : true
		},
		"opt2" : {
			"desc" : "Option #2 in group #1",
			"help" : "A help string for an options #2 in group 1",
			"type" : "number",
			"default" : 42,
			"validationCallback" : null,
			"range" : [0, 127]
		}
	},
	"Group 3" : {
		"opt1" : {
			"desc" : "Option #1 in group #3",
			"type" : "list",
			"default" : ["one", "three"],
			"selectedSize" : [1, 2],
			"validationCallback" : null,
			"data" : ["one", "two", "three", "four"]
		},
		"opt2" : {
			"desc" : "Option #2 in group #3",
			"type" : "text",
			"default" : "1q",
			"allowEmpty" : false,
			"range" : [2, 128]
		},
		"opt3" : {
			"desc" : "Option #3 in group #3",
			"type" : "datetime",
			"help" : "zzz",
			"default" : "2000-03-01T00:00:00Z",
			"allowEmpty" : true,
			"range" : ['2000-03-01T00:00:00Z', '2001-03-02T00:00:00Z']
		},
		"opt4" : {
			"desc" : "Option #4 in group #3",
			"type" : "date",
			"help" : "zzz",
			"default" : "2000-03-01",
			"allowEmpty" : true,
			"range" : ['2000-03-01', '2000-03-02']
		},
		"opt5" : {
			"desc" : "Option #5 in group #3",
			"type" : "week",
			"help" : "zzz",
			"default" : "2000-W01",
			"allowEmpty" : true,
			"range" : ['2000-W01', '2000-W04']
		}
	},
	"Group #4" : {
		"opt1" : {
			"desc" : "Option #1 in group #4",
			"help" : "A help string for an options #1 in group 4",
			"type" : "list",
			"default" : ["six"],
			"selectedSize" : [1, 1],
			"validationCallback" : null,
			"data" : ["five", "six", "seven"]
		}
	},
	"Group 5" : {
		"opt1" : {
			"desc" : "Option #1 in group #5",
			"help" : "A help string for an options #1 in group 5",
			"type" : "bool",
			"default" : true
		},
		"opt2" : {
			"desc" : "Option #2 in group #5",
			"help" : "A help string for an options #2 in group 5",
			"type" : "color",
			"default" : "#ff7f27"
		},
		"opt3" : {
			"desc" : "Option #3 in group #5",
			"help" : "A help string for an options #3 in group 5",
			"type" : "email",
			"default" : "joe@example.com",
			"allowEmpty" : false
		}
	}
}

var weakspec_opts = {}
weakspec_opts.header = "An example of a custom header."
