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