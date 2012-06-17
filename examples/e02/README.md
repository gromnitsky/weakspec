# weakspec e02 Example Extension

Adds a button. When user clicks on it, e02 rotates images on the current
page. You can change the angle of the rotation & a CSS query in the
preferences.

## The Point of a Demo

The main goal of weakspec is 'to handle preferences, write as little
code as possible.' You write `options.weakspec.js`--that's inevitable &
weakspec generates a usable preferences page on the fly, but that
doesn't solve another subtle problem:

### How do I get default values of preferences into my extension?

Sure, they will appear after user visits a preference page. But forcing
him to do that is lame. So you have to set the defaults while your
extension loads for the first time.

How do you do that?

You can make a fuss with checking every time 'was my foobar preference
set?' or somehow load and parse the contents of `options.weakspec.js`
from `index.html`. We'll take the later approach.

    extstorage.js
    populator.js

Are 2 files which you include into your `index.html` alongside with
`background.js` as:

    <script src="extstorage.js"></script>
    <script src="populator.js"></script>
    <script src="background.js"></script>

(Order _is_ significant.) Then add to your `background.js` 1 (one) line
of code:

    new WeakSpecPopulator('options.weakspec.js')

And that's all. If you have any errors in your `options.weakspec.js`,
the loading of the extension will halt. Look into the error console to
figure why.

### Getting the preferences from injected scripts

But we have another problem mentioned in weakspec's `README.md`:
`widget.preferences` object is not a hash, but a dumb flat key-value
store, where values are strings. weakspec bypass that by converting a
bunch of group values into a JSONified strings. You need a reverse that
operation to get to a particular preference value.

That's when `extstorage.js` can be symlinked to `includes` directory.

In your injected scripts just use

    ExtStorage.Get(group, name)
	
to extract the value from 'encrypted' `widget.preferences`. In some rare
cases when you need to update it, use

    ExtStorage.Set(group, name, value)

Enjoy.
