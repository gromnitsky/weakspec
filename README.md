## Building

    % gmake options.html

Run tests:

1. DOM-less part:

       % gmake

2. Browser related (with Jasmine):

       test/SpecRunner.html

## Bugs

* `range` for `text` preference works only for upper limit due to
  availability of `maxlength` html5 attribute for a textarea element but
  absence of `minlength`.
