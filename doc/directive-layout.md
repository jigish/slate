# The `layout` Directive #

The `layout` directive follows the following format:

```
layout name 'app name':OPTIONS operations
```

Where:

* `name` is the name you want to use to reference the layout,
* `'app name'` is a single-quoted name of the application to add to the layout **or** BEFORE or AFTER
* `OPTIONS` is a comma separated list of options for this application (cannot be used with BEFORE or AFTER)
* `operations` is a pipe separated list of operations (move, resize, push, nudge, throw, or corner)

Possible Options:

| Name | Function |
|:-----|:---------|
| `IGNORE_FAIL` | This will let slate move to the next operation if the current operation fails to resize/move on the current window |
| `REPEAT` | This will repeat the list of operations if the number of windows is larger than the number of operations |
| `REPEAT_LAST` | This will repeat the last operation in the list if the number of windows is larger than the number of operations |
| `MAIN_FIRST` | This will cause the main window to always use the first operation |
| `MAIN_LAST` | This will cause the main window to always use the last operation (mutally exclusive with `MAIN_FIRST`) |
| `SORT_TITLE` | This will cause the window operations to be triggered on the windows in sorted order by the window title (can be used with `MAIN_FIRST` or `MAIN_LAST`) |
| `TITLE_ORDER=order` | This will cause the operations to be triggered on the windows starting with order which is a semi-colon separated list of window titles |
| `TITLE_ORDER_REGEX=order` | This will cause the operations to be triggered on the windows starting with the order which is a semi-colon separated list of window title regexes to match. Note that once a match is seen, the next regex will be used to match. This means if you have two windows that match the same regex, only the first one seen will be matched. The second will not. |

You can have multiple layout directives that point to the same name in order to link any number of applications to the same layout.

Example:

```
layout myLayout 'iTerm' push up bar-resize:screenSizeY/2 | push down bar-resize:screenSizeY/2
layout myLayout 'Google Chrome' push left bar-resize:screenSizeX/2 | push right bar-resize:screenSizeX/2
layout myLayout BEFORE shell path:~/ '/opt/local/bin/mvim before'
layout myLayout AFTER shell path:~/ '/opt/local/bin/mvim after'
```

Will create a layout called `myLayout` with two operations for iTerm and two operations for Google Chrome. When activated, the first window of iTerm will be moved using the first operation in the first list and the second window of iTerm will be moved using the second operation in the first list. In addition, the first window of Google Chrome will be moved using the first operation in the second list and the second window of Google Chrome will be moved using the second operation in the second list. Finally, the operation `shell path:~/ '/opt/local/bin/mvim before'` will be run before any Applications are moved and the operation `shell path:~/ '/opt/local/bin/mvim after'` will be run after any Applications are moved. BEFORE and AFTER may also be used if the layout doesn't have any applications tied to it. Also, you may specify multiple BEFORE or AFTER lines (they will be run in the order that they appear). More information on how to actually use these layouts can be found under the `layout` operation in the `bind` directive section.
