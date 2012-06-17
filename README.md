# weakspec

Generates a usable preferences page for Opera extensions on the fly.

The motto: to handle preferences, write as little code as possible.

An [example](http://gromnitsky.github.com/weakspec/e01.html).


## Introduction

To fully incorporate weakspec into your extension, you'll need 3 files:

    options.html
    extstorage.js
    populator.js

They are all pre-compiled from CoffeeScript & can be found in
`for-extensions` directory.

The main one is `options.html`. It reads special `options.weakspec.js`
file, in which you specify a list of preferences (their groups, names,
types, default values, verification callbacks, etc). If
`options.weakspec.js` is valid, `options.html` automatically generate a
bunch of GUI elements, where users of your extension can set & check the
extension preferences.

That's very handy, I think. You don't need to write a boring
'preferences' code by yourself.

Please see `examples` directory for several ready extensions. e02 goes
into more details about other real life staff.


## Storage

All preferences are physically sit in `widget.preferences`
object. Unfortunately it is not a hash but a object similar to W3C
webstorage--a flat key-value store, where values can be only
strings.

weakspec encodes values into JSONified strings. To decode them, use 2
routines from `extstorage.js`. See e02 example extension.


## options.weakspec.js

A short example:

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

Spec requires 1 variable `weakspec`, which is a hash. A hash must
contain at least 1 group. Each group have unlimited number of
preferences. In the example above, we have 1 group named 'Rotation',
which have 2 preferences, named 'angle' & 'domquery'.

### Preference types

A 'type' key designates a GUI element for a preference & its additional
options. For example, 'number' type can hold only a JavaScript
number. If you supply an array or a string for it, validation will fail.

### Required options for all preference types

* `default`
  
  A default value. Cannot be null. A possible value depends on a type.
  
* `desc`

  A description string that will be drawn on the left side.
  
### Common options for all preference types

* `help`

   A help string that will popup if user hovers the '?' sign on the
   right.

* `validationCallback`

   A function that takes 1 argument--a _value_ and return `true` if
   value is valid & `false` otherwise. Use this if your preference is so
   complex that provided constraints cannot suit you. It
   `validationCallback` is present or != `null`, all other validation
   options are ignored.
   
### number

Any JS number, signed or unsigned.

#### Constrains

* `range`

   An array of 2 elements: min & max.

### string

A (probably short) JS string.

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

* `validationRegexp`

   A string that contains a JS regexp. The preference value will be
   checked against it.

### list

A fixed array of strings. Multi or single selectable.

#### Required Options

* `data`

   An array.

#### Constrains

* `selectedSize`

   A array of integers with 2 elements. For example:
   
        "foobar" : {
            "desc" : "...",
            "type" : "list",
            "default" : ["one", "three"],
            "selectedSize" : [1, 2],
            "validationCallback" : null,
            "data" : ["one", "two", "three", "four"]
        }

    `[1, 2]` in `selectedSize` means that min 1 element & max 2 elements
    if a list can be selected. If `selectedSize` would be equal to
    `[1, 1]` that means only 1 element can be selected.

### bool

A JS boolean: `true` or `false`.

### text

A JS string that can contain newlines.

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

* `range`

   An array of 2 elements: min string length & max string length.

### color

A string that represents color values in `#rrggbb` (a hex triplet)
format.

### email

A string that contain a valid email address.

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

### datetime

A string in UTC ISO 8601 format (without decimal fractions).

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

* `range`

   An array of 2 elements: min & max.

### date

A string in `YYYY-MM-DD` format.

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

* `range`

   An array of 2 elements: min & max.

### week

A string in `YYYY-WNN` format, where 'W' is a literal char & 'NN' is a number
[1...48].

#### Constrains

* `allowEmpty`

   A boolean. If `true`, the preference can contain empty string `""`.

* `range`

   An array of 2 elements: min & max.

### Additional Customization

`options.weakspec.js` can have `weakspec_opts` hash. At this moment, you
can supply with it a custom header displayed by `options.html`. For
example:

	var weakspec_opts = {}
	weakspec_opts.header = "<h1>Hi, Mom!</h1>"

Or any other valid html in `weakspec_opts.header`.


## Development

While constructing `options.weakspec.js` open `options.html` in Opera as
a any other local html page. You don't need to open it only from the
installed extension (but you can, of course). `widget.preferences`
object will be mocked.


## Building

    % gmake options.html

Run tests:

1. DOM-less part:

       % gmake

2. Browser related (with Jasmine):

       test/SpecRunner.html

## Bugs

* Names of groups & preferences cannot contain `|` char.

* `range` for `text` preference works only for upper limit due to
  availability of `maxlength` html5 attribute for a textarea element but
  absence of `minlength`.

* `datetime` expects iso 8601 format in UTC without decimal fractions.

* `time` is broken. Probably it's an Opera bug, because `<input
  type='time'>` cannot get through a validation phase.

## License

MIT.
