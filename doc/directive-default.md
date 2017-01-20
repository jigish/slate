# The `default` Directive #

The `default` directive follows the following format (tokens may be separated by any number of spaces):

```
default layout-or-snapshot-name screen-configuration
```

Where:

* `layout-or-snapshot-name` is the name of the layout or snapshot you want to default to
* `screen-configuration` is either `count:NUMBER_OF_SCREENS` or `resolutions:SEMICOLON_SEPARATED_LIST_OF_RESOLUTIONS`

This directive will cause any screen configuration change (add monitor, remove monitor, screen resolution change) to trigger a search for a default layout or snapshot. If the screen configuration matches one of the defaults set, the layout or snapshot matching `layout-or-snapshot-name` will be triggered. For example:

```
default myLayout count:2
```

Will trigger `myLayout` anytime the screen configuration changes to have 2 monitors. Also:

```
default myLayout2 resolutions:1440x900;1024x768;1680x1050
```

Will trigger `myLayout2` anytime the screen configuration changes to have exactly 3 monitors with resolutions `1440x900`, `1024x768`, and `1680x1050`.
