# About Slate #

Slate is a window management application similar to Divvy and SizeUp (except better and free!). Originally written to replace them due to some limitations in how each work, it attempts to overcome them by simply being extremely configurable. As a result, it may be a bit daunting to get configured, but once it is done, the benefit is huge.

Slate currently works on Mac OS X 10.6 and above

## Summary of Features ##

* Highly customizable
* Bind keystrokes to:
  * move and/or resize windows
  * directionally focus windows
  * activate preset layouts
  * create, delete, and activate snapshots of the current state of windows
* Set default layouts for different monitor configurations which will activate when that configuration is detected.
* Window Hints: an intuitive way to change window focus
* \[Beta\] A better, more customizable, application switcher.

## Credits ##

Big thanks to [philc](https://github.com/philc) for the Window Hints idea (and initial implementation) as well as plenty of other suggestions and improvement ideas.

# Using Slate #

## Installing Slate ##

**NEW Installation Instructions**

**Note:** You must turn on the Accessibility API by checking System Preferences > Universal Access > Enable access for assistive devices

### Direct Download ###

* [`.dmg`](http://slate.ninjamonkeysoftware.com/Slate.dmg)
* [`.tar.gz`](http://slate.ninjamonkeysoftware.com/versions/slate-latest.tar.gz)

### Terminal ###

Just run this in your terminal:

    cd /Applications && curl http://www.ninjamonkeysoftware.com/slate/versions/slate-latest.tar.gz | tar -xz

## Configuring Slate ##

**BETA:** You may now use a ".slate.js" file to configure slate using JavaScript. This allows for much more complex and dynamic configurations that the normal slate configuration style below. You can check out the documentation for this [here](https://github.com/jigish/slate/wiki/JavaScript-Configs).

Slate is configured using a ".slate" file in the current user's home directory. Configuration is loaded upon running Slate. You can also re-load the config using the "Load Config" menu option on the status menu (use this at your own risk. It is better to simply restart Slate).

**Note:** If no ".slate" file exists in the current user's home directory, the [default config file](https://github.com/jigish/slate/blob/master/Slate/default.slate) will be used.

Configuration is split into the following directives:

* `config` (for global configurations)
* `alias` (to create alias variables)
* `layout` (to configure layouts)
* `default` (to default certain screen configurations to layouts)
* `bind` (for key bindings)
* `source` (to load configs from another file)

**Note:** `#` is the comment character. Anything after a `#` will be ignored.

###Expressions###

Some directives allow parameters that can be expressions. The following strings will be replaced with the appropriate values when using expressions:

    screenOriginX = target screen's top left x coordinate (should not be used in Window Hints configs)
    screenOriginY = target screen's top left y coordinate (should not be used in Window Hints configs)
    screenSizeX = target screen's width
    screenSizeY = target screen's height
    windowTopLeftX = window's current top left x coordinate (should not be used in Window Hints configs)
    windowTopLeftY = window's current top left y coordinate (should not be used in Window Hints configs)
    windowSizeX = window's width
    windowSizeY = window's height
    newWindowSizeX = window's new width (after resize, only usable in topLeftX and topLeftY, should not be
                     used in configs)
    newWindowSizeY = window's new height (after resize, only usable in topLeftX and topLeftY, should not be
                     used in configs)
    windowHintsWidth = the value of the windowHintsWidth config (only usable in windowHintsTopLeftX and
                       windowHintsTopLeftY)
    windowHintsHeight = the value of the windowHintsHeight config (only usable in windowHintsTopLeftX and
                        windowHintsTopLeftY)

In addition to the variables above, expressions can be used with the following functions and operators:

    +          e.g. 1+1 = 2
    -          e.g. 1-1 = 0
    *          e.g. 2*2 = 4
    /          e.g. 4/2 = 2
    **         e.g. 3**2 = 9
    sum        e.g. sum({1,2,3}) = 6
    count      e.g. count({4,5,6}) = 3
    min        e.g. min({1,3,5}) = 1
    max        e.g. max({1,3,5}) = 5
    average    e.g. average({1,2,3,4}) = 2.5
    median     e.g. median({1,2,3,10,15}) = 3
    stddev     e.g. stddev({1,2,3,4,5}) = 1.4142135623730951
    sqrt       e.g. sqrt(9) = 3.0
    log        e.g. log(100) = 2.0
    ln         e.g. ln(8) = 2.0794415416798357
    exp        e.g. exp(2) = 7.3890560989306504 (this is "e**parameter")
    floor      e.g. floor(1.9) = 1.0
    ceiling    e.g. ceiling(1.1) = 2.0
    abs        e.g. abs(-1) = 1
    trunc      e.g. trunc(1.1123123123) = 1.0
    random     e.g. random() = 0.20607629744336009 (random float between 0 and 1)
    randomn    e.g. randomn(10) = 4 (random integer between 0 and parameter-1)

**Note:** When using expressions spaces are *not* allowed!

### The `config` Directive ###

The `config` directive follows the following format:

    config name value

List of allowed configs:

| Name | Type | Behavior |
|:-----|:-----|:---------|
| `defaultToCurrentScreen` | Boolean | Default: `false`. `true` causes all bindings to default to the current screen if the screen the reference does not exist. `false` causes only bindings that do not specify a screen to default to the current screen while bindings that reference screens that do not exist simply do nothing. |
| `nudgePercentOf` | String | Default: `screenSize`. Will use this value for the nudge percent calculation. Possible values are `windowSize` and `screenSize`. |
| `resizePercentOf` | String | Default: `screenSize`. Will use this value for the resize percent calculation. Possible values are `windowSize` and `screenSize`. |
| `repeatOnHoldOps` | String | Default: `resize,nudge`. Comma separated list of operations that should repeat when the hotkey is held. |
| `secondsBeforeRepeat` | Number | Default: `0.4`. The number of seconds before repeating starts (for ops in `repeatOnHoldOps`) |
| `secondsBetweenRepeat` | Number | Default: `0.1`. The number of seconds between repeats (for ops in `repeatOnHoldOps`) |
| `checkDefaultsOnLoad` | Boolean | Default: `false`. `true` causes the default directives to be checked/triggered after any configuration load |
| `focusCheckWidth` | Integer | Default: `100`. The width (in pixels) of the rectangle used to check directions in the focus directive. Only used for right, left, up, above, down, and below directions. The larger this is, the futher away focus will check for adjacent windows. Consequently, the larger this is, the more irritatingly stupid focus can be. |
| `focusCheckWidthMax` | Integer | Default: `100`. If set to anything above focusCheckWidth, the focus option will keep expanding the rectangle used to check directions by focusCheckWidth if it does not find a window until it either finds a window or the width of the rectangle is greater than `focusCheckWidthMax` |
| `focusPreferSameApp` | Boolean | Default: `true`. When this is `true`, the focus operation will *always* choose a window in the same app to focus if it exists in the check width regardless of intersection size. When this is `false`, focus will treat all application windows the same and choose the largest intersection size |
| `orderScreensLeftToRight` | Boolean | Default: `true`. When this is `true`, monitors will be ordered from left to right by X coordinate (if two X coordiates are the same, then the lowest Y coordinate will be first). When this is `false`, screens will be ordered according to the internal Mac OS X ordering which changes depending on which screen was plugged in first. If this is `false`, you can force ordering of screens by prefixing the screen ID with `ordered:` |
| `windowHintsBackgroundColor` | Semicolon Separated Array of Floats | Default: `50;53;58;0.9`. The background color for Window Hints as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `windowHintsWidth` | Expression | Default: `100`. The width of the Window Hints ovelay in pixels. Please see the "Expressions" section above more information on expressions. |
| `windowHintsHeight` | Expression | Default: `100`. The height of the Window Hints overlay in pixels. Please see the "Expressions" section above more information on expressions. |
| `windowHintsFontColor` | Semicolon Separated Array of Floats | Default: `255;255;255;1.0`. The font color for Window Hints as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `windowHintsFontName` | String | Default: `Helvetica`. The name of the Window Hints font |
| `windowHintsFontSize` | Integer | Default: `40`. The size of the Window Hints font |
| `windowHintsDuration` | Number | Default: `3`. The number of seconds that Window Hints will display for |
| `windowHintsRoundedCornerSize` | Integer | Default: `5`. The size of the rounded corners of the Window Hints. Set this to `0` if you do not want rounded corners |
| `windowHintsIgnoreHiddenWindows` | Boolean | Default: `true`. If this is set to `true`, window hints will not show for windows that are hidden. Hints will show for all windows if this is `false`. A window is hidden if the window under the point at the center of where the hint overlay would show is not the window in question. |
| `windowHintsTopLeftX` | Semicolon Separated Array of Expressions | Default: `(windowSizeX/2)-(windowHintsWidth/2);0`. The X offset for window hints from the window's top left point (right is positive, left is negative). If `windowHintsIgnoreHiddenWindows` is set to `true`, the `hint` operation will try each expression in this array (using the Y coordinate from the same index in `windowHintsTopLeftY`) sequetially to see if it represents a point that is visible. The `hint` operation will display a hint at the first visible point. Note that the number of elements in this array *must* equal the number of elements in `windowHintsTopLeftY` or all `hint` bindings will fail validation. |
| `windowHintsTopLeftY` | Semicolon Separated Array of Expressions | Default: `(windowSizeY/2)-(windowHintsHeight/2);0`. The Y offset for window hints from the window's top left point (down is positive, up is negative). If `windowHintsIgnoreHiddenWindows` is set to `true`, the `hint` operation will try each expression in this array (using the X coordinate from the same index in `windowHintsTopLeftX`) sequetially to see if it represents a point that is visible. The `hint` operation will display a hint at the first visible point. Note that the number of elements in this array *must* equal the number of elements in `windowHintsTopLeftX` or all `hint` bindings will fail validation. |
| `windowHintsOrder` | `none`, `persist`, `leftToRight`, or `rightToLeft` | Default: `leftToRight`. Specifies the ordering of windows for Window Hints. If `none`, hints will be seemingly randomly ordered. If `persist`, hints will be randomly ordered but will remain the same throughout the life of the window (Currently does not work if windows have the same title). If `leftToRight`, hints will be ordered from the left of the screen to the right of the screen. If `rightToLeft`, hints will be ordered from the right of the screen to the left of the screen |
| `windowHintsShowIcons` | Boolean | Default: `false`. If true, the application's icon will be shown as a background for the letter instead of the rectangle. This is useful if `windowHintsIgnoreHiddenWindows` is false so that you can know which application a hint for a hidden window belongs to.|
| `windowHintsSpread` | Boolean | Default: `false`. If true, hints in the same place will be spread out vertically. This is useful if `windowHintsIgnoreHiddenWindows` is false so that multiple windows with the same center will have distinct hints.|
| `windowHintsSpreadSearchWidth` | Number | Default: `40`. The width in pixels of the search box for hint collisions. Other hints within this box will be spread down.|
| `windowHintsSpreadSearchHeight` | Number | Default: `40`. The height in pixels of the search box for hint collisions. Other hints within this box will be spread down.|
| `windowHintsSpreadPadding` | Number | Default: `20`. The pading between hint boxes which have been spread downwards.|
| `switchIconSize` | Number | Default: `100`. The size of the application icons for the `switch` operation |
| `switchIconPadding` | Number | Default: `5`. The padding around the application icons for the `switch` operation |
| `switchBackgroundColor` | Semicolon Separated Array of Floats | Default: `50;53;58;0.3`. The background color for the `switch` operation as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `switchSelectedBackgroundColor` | Semicolon Separated Array of Floats | Default: `50;53;58;0.9`. The selected background color for the `switch` operation as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `switchSelectedBorderColor` | Semicolon Separated Array of Floats | Default: `230;230;230;0.9`. The selected border color for the `switch` operation as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `switchSelectedBorderSize` | Number | Default: `2`. The size of the selected border of the `switch` operation. Set this to `0` if you do not a border |
| `switchRoundedCornerSize` | Number | Default: `5`. The size of the rounded corners of the `switch` operation. Set this to `0` if you do not want rounded corners |
| `switchOrientation` | `horiztonal` or `vertical` | Default: `horizontal`. Which direction to grow the application switcher. |
| `switchSecondsBeforeRepeat` | Number | Default: `0.4`. The number of seconds before repeating starts for forward/back keypresses for the switch operation |
| `switchSecondsBetweenRepeat` | Number | Default: `0.05`. The number of seconds between repeating the forward/back keypresses for the switch operation. |
| `switchStopRepeatAtEdge` | Boolean | Default: `true`. If `true`, when holding down the switch operation forward/back keys repeats will trigger until the selected app reaches the end/beginning of the list. If `false`, holding down the switch operation forward/back keys will cycle through the app list without stopping |
| `switchOnlyFocusMainWindow` | Boolean | Default: `true`. If `true`, the switch operation will only bring the main window of the selected app forward. If `false`, the switch operation will work similar to the default application switcher and bring all windows of the selected app forward. |
| `switchShowTitles` | Boolean | Default: `false`. If `true`, the switch operation will show the title of the items in the list as well. |
| `switchFontColor` | Semicolon Separated Array of Floats | Default: `255;255;255;1.0`. The font color for the `switch` operation as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `switchFontName` | String | Default: `Helvetica`. The name of the `switch` operation title font |
| `switchFontSize` | Number | Default: `14`. The size of the `switch` operation font |
| `switchType` | `app` or `window` | Default: `app`. \[UNIMPLEMENTED - coming in 1.1\] If `app`, the `switch` operation will present a list of applications ordered by last focus. If `window` the `switch` operation will present a list of windows ordered by last focus. |
| `switchSelectedPadding` | Number | Default: `10`. The size of the padding betweeen the edge of the switch window and the edge of the selected app selected background |
| `keyboardLayout` | `dvorak`, `colemak`, `azerty` or `qwerty` | Default: `qwerty`. The keyboard layout you are using. |
| `snapshotTitleMatch` | `levenshtein` or `sequential` | Default: `levenshtein`. The algorithm to use when determining if titles match or not for the snapshot operation. If `levenshtein`, the titles with the lowest levenshtein distance will be matched, if sequential, the titles with the maximum common prefix length will be matched. Note that this will change the algorithm for **all** apps. If you would like to change the algorithm for only one app use `snapshotTitleMatch:'APP_NAME'` for example to change the algorithm for only iTerm, use the following directive: `config snapshotTitleMatch:'iTerm' sequential`. |
| `snapshotMaxStackSize` | Integer | Default: `0`. The size of the stack to keep when creating snapshots using the `stack` option. If <= 0, the size of the stack will be unlimited. |
| `gridBackgroundColor` | Semicolon Separated Array of Floats | Default: `75;77;81;1.0`. The background color for the `grid` operation as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `gridRoundedCornerSize` | Number | Default: `5`. The size of the rounded corners of the `grid` operation's background. Set this to `0` if you do not want rounded corners |
| `gridCellBackgroundColor` | Semicolon Separated Array of Floats | Default: `75;77;81;1.0`. The background color for the `grid` operation's cells as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `gridCellSelectedColor` | Semicolon Separated Array of Floats | Default: `75;77;81;1.0`. The selected color for the `grid` operation's cells as an array in the form `Red;Green;Blue;Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `gridCellRoundedCornerSize` | Number | Default: `5`. The size of the rounded corners of the `grid` operation's cells. Set this to `0` if you do not want rounded corners |
| `layoutFocusOnActivate` | Boolean | Default: `false`. If true, activating a layout will focus all windows touched by the layout. The order in which they will be focused is the order in which the Applications occur in the slate file. Thus, the last Application configured in the slate file will be the foremost application after the layout is triggered. If set to false, activating a layout will not focus any of the windows touched. Thus the foremost application after the layout is triggered will be the foremost application before the layout was triggered. |
| `undoMaxStackSize` | Integer | Default: `10`. The size of the stack to keep when creating undo snapshots. If <= 0, the size of the stack will be unlimited. This is effectively the number of times you can use the `undo` binding to undo Slate operations. |
| `undoOps` | String | Default: `activate-snapshot,chain,grid,layout,move,resize,sequence,shell`. The list of undoable operations. Any operation in this list will take a snapshot before activation to allow undoing it. This may decrease performance. Snapshots will only be taken if an undo operation exists in your config. |
| `modalEscapeKey` | String | Default: `` (empty string). This is the keystroke that will end modal mode (in addition to the keystroke that started modal mode itself). For example setting this to `esc` will allow you to press `esc` after entering modal mode to exit modal mode. You may specify an entire keystroke with modifiers here e.g. `esc:ctrl`. |

Example:

    config defaultToCurrentScreen true

### The `alias` Directive ###

The `alias` directive follows the following format:

    alias name value

When you set an alias, you can refer to it in any directive (sequentially after that alias directive) by referencing like `${name}`.

Example:

    alias bot-right-2nd-mon move screenOriginX+2*screenSizeX/3;screenOriginY+screenSizeY/2 screenSizeX/3;screenSizeY/2 1

Will allow you to use `${bot-right-2nd-mon}` as a reference to `move screenOriginX+2*screenSizeX/3;screenOriginY+screenSizeY/2 screenSizeX/3;screenSizeY/2 1` in any directive following the alias (including other alias directives)

### The `layout` Directive ###

The `layout` directive follows the following format:

    layout name 'app name':OPTIONS operations

Where:

    name = the name you want to use to reference the layout
    'app name' = single-quoted name of the application to add to the layout **or** BEFORE or AFTER
    OPTIONS = a comma separated list of options for this application (cannot be used with BEFORE or AFTER)
    operations = a pipe separated list of operations (move, resize, push, nudge, throw, or corner)

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

    layout myLayout 'iTerm' push up bar-resize:screenSizeY/2 | push down bar-resize:screenSizeY/2
    layout myLayout 'Google Chrome' push left bar-resize:screenSizeX/2 | push right bar-resize:screenSizeX/2
    layout myLayout BEFORE shell path:~/ '/opt/local/bin/mvim before'
    layout myLayout AFTER shell path:~/ '/opt/local/bin/mvim after'

Will create a layout called `myLayout` with two operations for iTerm and two operations for Google Chrome. When activated, the first window of iTerm will be moved using the first operation in the first list and the second window of iTerm will be moved using the second operation in the first list. In addition, the first window of Google Chrome will be moved using the first operation in the second list and the second window of Google Chrome will be moved using the second operation in the second list. Finally, the operation `shell path:~/ '/opt/local/bin/mvim before'` will be run before any Applications are moved and the operation `shell path:~/ '/opt/local/bin/mvim after'` will be run after any Applications are moved. BEFORE and AFTER may also be used if the layout doesn't have any applications tied to it. Also, you may specify multiple BEFORE or AFTER lines (they will be run in the order that they appear). More information on how to actually use these layouts can be found under the `layout` operation in the `bind` directive section.

### The `default` Directive ###

The `default` directive follows the following format (tokens may be separated by any number of spaces):

    default layout-or-snapshot-name screen-configuration

Where:

    layout-or-snapshot-name = the name of the layout or snapshot you want to default to
    screen-configuration = either "count:NUMBER_OF_SCREENS" or
                                  "resolutions:SEMICOLON_SEPARATED_LIST_OF_RESOLUTIONS"

This directive will cause any screen configuration change (add monitor, remove monitor, screen resolution change) to trigger a search for a default layout or snapshot. If the screen configuration matches one of the defaults set, the layout or snapshot matching `layout-or-snapshot-name` will be triggered. For example:

    default myLayout count:2

Will trigger `myLayout` anytime the screen configuration changes to have 2 monitors. Also:

    default myLayout2 resolutions:1440x900;1024x768;1680x1050

Will trigger `myLayout2` anytime the screen configuration changes to have exactly 3 monitors with resolutions `1440x900`, `1024x768`, and `1680x1050`.

### The `bind` Directive ###

The `bind` directive follows one of the following formats (tokens may be separated by any number of spaces):

    bind key:modifiers operation parameter+
    bind key:modal-key operation parameter+

#### Key ####

`key` is a reference to a key on the keyboard. See Allowed Keys for a complete list. For example: the `s` key would simply be `s` while the `1` key on the number pad would be `pad1`.

#### Modifiers ####

`modifiers` is a comma or semicolon separated list of standard modifier keys. Allowed modifiers are:

* Control: `ctrl`
* Option/Alt: `alt`
* Command: `cmd`
* Shift: `shift`
* Function: `fn` (currently does not work with arrow keys)

**Note:** If you bind any binding to cmd-tab or cmd-shift-tab, Slate will completely disable the default Mac OS X Application switcher!

**Note:** Bindings that are used by Mac OS X spaces, expose, and mission control will override Slate bindings. Be sure to turn these bindings off if you want to use them in Slate.

#### Modal Key ####

`modal-key` is any one of the Allowed Keys. If using a `modal-key`, pressing that key will cause the Slate menu bar icon to change indicating modal mode is activated. then clicking `key` will activate the binding. Modal mode will remain active until `key` has been pressed or `modal-key` is pressed again. You may specify multiple bindings with the same `modal-key` as long as `key` is different. Also, `modal-key` can accompany a comma or semicolon separated list of modifier keys listed above. This will cause that entire keystroke to be considered the modal activation binding. For example: `bind 1:f4,ctrl,alt` will result in the modal keystroke being `ctrl+alt+f4`. After pressing that keystroke, modal mode will be activated and pressing `1` after that will activate the binding.

##### Modal Toggle Behavior #####

If you add `:toggle` to the end of a modal binding it will cause that binding to not end the modal mode. For example with the binding `1:ctrl,f4`, you press `ctrl+f4` and then press `1` to activate the binding. Once that binding is activated, modal mode will end and you have to press `ctrl+f4` again to activate it. However, with the binding `1:ctrl,f4:toggle` pressing `ctrl+f4` will toggle modal mode. pressing `1` will activate the binding but not end modal mode. To end modal mode, press `ctrl+f4` again or use the config `modalEscapeKey`.

#### Operation ####

Operations define what to actually do to the focused window.

**Screens**

Some operations allow you to specify a screen. Here are the list of possible values for screen:

* Integer representing the screen ID (indexed at 0). Screens are ordered from left to right (by X coordinate of the origin which is the top-left point). If `orderScreensLeftToRight` is set to false, the screen ID is the Mac OS internal ID (indexed at 0). If `orderScreensLeftToRight` is set to false but you still want to reference screens in the default ordered mode, prefix the screen ID with `ordered:`.
* Screen resolution in the format `WIDTHxHEIGHT` (e.g. `1440x900`)
* Screen direction relative to the current screen (`left|right|up|above|down|below`)
* `next` or `previous` (represents the `currentID+1` or `currentID-1` screen)

**Allowed operations are:**

##### move #####
Move/Resize the window any which way: `move topLeftX;topLeftY sizeX;sizeY screen`

        topLeftX = top left x coordinate of the window's desired position (can be an expression)
        topLeftY = top left y coordinate of the window's desired position (can be an expression)
        sizeX = width of the window's desired position (can be an expression)
        sizeY = height of the window's desired position (can be an expression)
        screen = (optional) the reference to the screen of the window's desired position.
                 If this is not specified, it will default to the screen the window is currently on.
                 See the table at the beginning of the Operation section for more information.

    Example:

        bind pad1:ctrl move 0;0 100;100 1

    Will bind the keystroke ctrl-numpad1 to moving the window to the screen at index `1` with top-left coordinate `0,0` and size `100,100`

    **Note:** Remember to offset with `screenOriginX` in your `topLeftX` and `screenOriginY` in your `topLeftY` when using the `screen` option (or when using multiple screens in general) or your move operation will offset from the default origin `(0,0)` which is the origin of screen `0`.

##### resize #####
Resize the window (keeping top-left the same): `resize x y anchor`

        x = amount to resize width either as a percent or a hard value (+10% or -100)
        y = amount to resize height either as a percent or a hard value (+10% or -100)
        anchor = (optional) which corner to anchor on top-left|top-right|bottom-left|bottom-right (default is top-left)

    Example:

        bind right:ctrl resize +10% +0

    Will bind the keystroke ctrl-rightarrow to increase the width the current window by `10%`.

    **Note:** ctrl-rightarrow is used by default in Mac OS X by spaces. Be sure to turn these bindings off if you want to use them in Slate.

##### push #####
Push the window to the edge of the screen: `push direction style`

        direction = top|up|bottom|down|left|right
        style = (optional) none|center|bar|bar-resize:expression (default is none)
        screen = (optional) the reference to the screen of the window's desired position.
                 If this is not specified, it will default to the screen the window is currently on.
                 See the table at the beginning of the Operation section for more information.

    Example:

        bind up:alt,ctrl push up

    Will bind the keystroke alt-ctrl-uparrow to push the window so that it is aligned with the top of the screen

##### nudge #####
Nudge the window in any direction: `nudge x y`

        x = amount to nudge x either as a percent or a hard value (+10% or -100)
        y = amount to nudge y either as a percent or a hard value (+10% or -100)

    Example:

        bind left:ctrl,shift nudge -100 +0

    Will bind the keystroke ctrl-shift-leftarrow to nudge the window `100` pixels to the left

##### throw #####
Throw the window to any screen's origin: `throw screen style`

        screen = the screen you want to throw the window to (0 indexed)
        style = (optional) resize|resize:x-expression;y-expression (default will not resize)

    Example:

        bind pad1:alt,ctrl throw 1 resize

    Will bind the keystroke alt-ctrl-numpad1 to throw the window to the 2nd screen and resize it to fit that screen

##### corner #####
Move/Resize the window into a corner: `corner direction style`

        direction = top-left|top-right|bottom-left|bottom-right
        style = (optional) resize:x-expression;y-expression (default will not resize)
        screen = (optional) the reference to the screen of the window's desired position.
                 If this is not specified, it will default to the screen the window is currently on.
                 See the table at the beginning of the Operation section for more information.

    Example:

        bind 1:ctrl corner top-left resize:screenSizeX/2;screenSizeY/2

    Will bind the keystroke ctrl-1 to move the window to the top-left corner and resize it to 1/4 of the screen

##### shell #####
Execute a shell command: `shell options 'command'`

        command = (required) the command to run. note that it is a quoted string.
        options = (optional) a space separated list of:
                   wait  - block slate until the shell command exits. Useful when using shell commands in a
                           sequence binding
                   path: - the inital working directory to use when starting the command. For example
                           path:~/code would set the inital working directory to ~/code

    Example:

        bind 1:ctrl wait path:~/code '/opt/local/bin/mvim'

    Will bind the keystroke ctrl-1 to run the command `/opt/local/bin/mvim` with the current working directory of `~/code`. Slate will also block until the command is done. Note that you may **not** use the tilda home directory shortcut within the command itself, it is only allowed within the path.

##### hide #####
Hide one or more applications: `hide applications`

        applications = a comma separated list of application names. Individual application names must be
                       surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the
                       Application name (no quotes). `current` will apply to the currently focused
                       application, `all` will apply to all open applications and `all-but:'APP_NAME'` will
                       apply to all open applications except `APP_NAME`. Note that when trying to hide `all`
                       it will not work as intended because OS X will not allow every visible app to be
                       hidden. Hiding `all` will hide all apps but OS X will auto-show one of the apps that
                       were hidden.

    Example:

        bind 1:ctrl hide 'iTerm','Google Chrome'

    Will bind the keystroke ctrl-1 to hide iTerm and Google Chrome.

##### show #####
Show one or more applications: `show applications`

        applications = a comma separated list of application names. Individual application names must be
                       surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the
                       Application name (no quotes). `current` will apply to the currently focused
                       application, `all` will apply to all open applications and `all-but:'APP_NAME'` will
                       apply to all open applications except `APP_NAME`.

    Example:

        bind 1:ctrl show 'iTerm','Google Chrome'

    Will bind the keystroke ctrl-1 to show (unhide) iTerm and Google Chrome.

##### toggle #####
Toggle one or more applications: `toggle applications`

        applications = a comma separated list of application names. Individual application names must be
                       surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the
                       Application name (no quotes). `current` will apply to the currently focused
                       application, `all` will apply to all open applications and `all-but:'APP_NAME'` will
                       apply to all open applications except `APP_NAME`. Note that when trying to toggle `all`
                       it will may not work as intended because OS X will not allow every visible app to be
                       hidden. If at any point during the toggling all apps become hidden, OS X will auto-show
                       one of the apps that were hidden.

    Example:

        bind 1:ctrl toggle 'iTerm','Google Chrome'

    Will bind the keystroke ctrl-1 to toggle iTerm and Google Chrome. Toggle meaning if the individual
    application is currently hidden it will be shown and if it is currently shown it will be hidden.

    **Note:** If you specify current in this toggle operation it will not toggle properly because after the current application is hidden, it is no longer the current application anymore.

##### chain #####
Chain multiple operations to one binding: `chain opAndParams1 | opAndParams2 ...`

        opAndParamsX = any operation string (except sequence, hint and grid)

    Example:

        bind 1:ctrl chain push up | push right | push down | push left

    Will bind the keystroke ctrl-1 to push up on the first press, then push right on the second press, then push down on the third press, the push left on the fourth press and rotate back to pushing up on the fifth press (etc).

##### sequence #####
Activate a sequence of operations in one binding: `sequence opAndParams1 separator opAndParams 2 ...`

        opAndParamsX = any of the above operation strings (except chain and grid. hint must be last if present)
        separator = | or >. | will cause the next operation to be performed on the window focused at the time of
                    execution of that operation, > will cause the next operation to be performed on the window
                    focused at the start of the > chain.

    Example:

        bind 1:ctrl sequence focus right > push left | push right

    Will bind the keystroke ctrl-1 to first focus the window to the right, then push the previously focused window to the left, then push the newly focused window to the right. Obviously Hint will ignore `>` and `|` and just display because it doesn't care which window was focused.


##### layout #####
Activate a layout: `layout name`

        name = the name of the layout to activate (set using the layout directive)

    Example:

        bind 1:ctrl layout myLayout

    Will bind the keystroke ctrl-l to activate the layout called `myLayout`. Note that the layout **must** be created before you bind it.

##### focus #####
Focus a window in a direction or from an application: `focus direction|app`

        direction = right|left|up|above|down|below|behind
        app = an app name surrounded by quotes

    Example:

        bind 1:ctrl focus above

    Will bind the keystroke ctrl-1 to focus the window Slate finds to be above the currently focused window (from any application). Minimized and hidden windows are ignored. A couple global configuration options set using the `config` directive exist to tweak this. Also, up and above are the same. Down and below are also the same.

        bind 1:ctrl focus 'iTerm'

    Will bind the keystroke ctrl-1 to focus the main window of the application iTerm. The main window is the last focused window of that application.

##### snapshot #####
Create a snapshot of your current window locations: `snapshot name options`

        name = the name of the snapshot to create (used in delete-snapshot and activate-snapshot)
        options = (optional) a semicolon separated list of any of the following options:
          save-to-disk -> saves the snapshot to disk so Slate will load it when it starts up next
          stack -> treats this snapshot as stack so you can use this binding multiple times to push snapshots on the stack

    Example:

         bind 1:ctrl snapshot theName save-to-disk;stack

    Will bind the keystroke ctrl-1 to create a snapshot called `theName`, save that snapshot to disk, and treat it as a stack so you can hit the keystroke multiple times to push snapshots onto the stack.

    **Note:** There is a menu option to take a snapshot of the current screen configuration.

##### delete-snapshot #####
Delete a snapshot: `delete-snapshot name options`

        name = the name of the snapshot to delete
        options = (optional) a semicolon separated list of any of the following options:
          all -> if the snapshot is a stack (if it isn't, this option is useless), this will delete all snapshots in the
                 stack (if this option is not specified, the default is to only delete the top snapshot of the stack).

    Example:

        bind 1:ctrl delete-snapshot theName all

    Will bind the keystroke ctrl-1 to delete the snapshot called `theName` if it exists. This will delete all instances of theName meaning if you have pushed multiple snapshots on the stack, it will completely clear them all.

##### activate-snapshot #####
Activate a snapshot: `activate-snapshot name options`

        name = the name of the snapshot to delete
        options = (optional) a semicolon separated list of any of the following options:
          delete -> this will delete the snapshot after activating it (if the snapshot is a stack, it will pop the top
                    snapshot off and keep the rest)

    Example:

        bind 1:ctrl activate-snapshot theName delete

    Will bind the keystroke ctrl-1 to activate the snapshot called `theName` if it exists. This will also delete the snapshot (or pop it off the stack if the snapshot is a stack).

    **Note:** There is a menu option to activate the snapshot that you may have created using the menu option.

##### hint #####
Show Window Hints (similar to Link Hints in Vimium except for Windows): `hint characters`

        characters = (optional) a simple string of characters to be used for the hints. each hint consists of one
                     character. if there are more windows than characters then some windows will not get hints.
                     this string can contain any of the single character Allowed Keys. Letters may be upper case or
                     lower case, but both will be bound to the lowercase letter for the hint. Using upper or lower
                     case only changes how they are displayed. The default string of characters is
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    Example:

        bind 1:ctrl hint QWERTYUIOP

    Will bind the keystroke ctrl-1 to show Window Hints using the letters `Q`, `W`, `E`, `R`, `T`, `Y`, `U`, `I`, `O`, and `P`.  This will show an overlay in the top-left corner of every window on screen containing one of those letters. While the overlays are showing, if one of those letters is pressed, the corresponding window will be focused. If there are more than 10 windows, some windows will not get hints. Pressing ESC will dismiss the hints.

    **Note:** There are *tons* of config options to tweak this.

##### grid #####
Show a Grid to one-off resize and move windows: `grid options`

        options is a whitespace separated list of:
          padding:<integer> = the padding between cells
          screenRef:width,height = width and height are integers specifying the width and height of the grid
                                   (number of cells, not absolute size). screenRef is either the screenID or
                                   screen resolution (widthxheight)

    Example:

        bind 1:ctrl grid padding:5 1680x1050:16,9 1050x1680:9,16

    Will bind the keystroke ctrl-1 to show Grids on each screen. The default width and height are 12. This will set the padding between the cells to be 5. Also, this will change the width and height of the grid on the monitor with the resolution 1680x1050 to 16 and 9 respectively. For the monitor with the resolution 1050x1680, it will set the width to 9 and height to 16. If you have multiple monitors, the Grid that is on the same screen as your mouse pointer will be focused. If you want to use a grid on a different monitor you **must** click it first and then click+drag.

    **Note:** There are a bunch of config options to tweak how this looks.

##### relaunch #####
Relaunch Slate: `relaunch`

    Example:

        bind 1:ctrl relaunch

    Will bind the keystroke ctrl-1 to relaunch Slate. This will also reload the `.slate` file from scratch.

##### undo #####
Undo an Operation: `undo`

    Example

        bind 1:ctrl undo

    Will bind the keystroke ctrl-1 to undo the last binding that was triggered. By default you can undo up to the last 10 commands. This can be changed using the `undoMaxStackSize` config. Also, you can only undo movement-based operations. Focus-related operations will not undo.

##### switch #####
\[Beta\] A Better Application Switcher: `switch`

    If you bind any binding to cmd-tab or cmd-shift-tab, Slate will completely disable the default Mac OS X Application switcher!

    Example:

        bind tab:cmd switch

    Will disable the default Mac OS X Application switcher and bind the keystroke cmd-tab to a better application switcher.

     **Note:** There are *tons* of config options to tweak this.

### The `source` Directive ###

The source directive follows the following format (tokens may be separated by any number of spaces):

    source filename optional:if_exists

Where `filename` is the name of a file containing any of the directives above (including source). If no absolute path is specified, the user's home directory will be prepended to `filename`. If the user specifies the option `if_exists` as the second argument, Slate will not complain if it cannot find the file.

For Example:

    source ~/.slate.test if_exists

Will append all of the configurations from the file `~/.slate.test` to the current configuration if the file `~/.slate.test` exists.

**Note:** You may use any aliases, layouts, etc that you specify before the source directive in the file you source. Any aliases, layouts, etc specified after cannot be used. Additionally, any aliases, layouts, etc that you specify in the file you source can be used after the source directive.

### Example Config ###

You can check out my own config [here](https://github.com/jigish/dotfiles/blob/master/slate).

### Useful Stuff ###

- [kvs](https://github.com/kvs) has created a [Sublime Text 2](http://www.sublimetext.com/2) preference for `.slate` files [here](https://github.com/kvs/ST2Slate).
- [trishume](https://github.com/trishume) has done a really nice writeup on getting started with Slate [here](http://thume.ca/howto/2012/11/19/using-slate/)

# Contact #

Please send all questions, bug reports, suggestions, or general commentary to [Jigish Patel](mailto:slate.issues@gmail.com) or [create an issue](https://github.com/jigish/slate/issues/new) on github.

# Allowed Keys #

**Note:** If you bind any binding to cmd-tab or cmd-shift-tab, Slate will completely disable the default Mac OS X Application switcher!

    '
    ,
    -
    .
    /
    0
    1
    2
    3
    4
    5
    6
    7
    8
    9
    ;
    =
    `
    a
    b
    backslash
    c
    caps
    d
    delete
    down
    e
    end
    esc
    f
    f1
    f10
    f11
    f12
    f13
    f14
    f15
    f16
    f17
    f18
    f19
    f2
    f20
    f3
    f4
    f5
    f6
    f7
    f8
    f9
    g
    h
    help
    home
    i
    j
    k
    l
    left
    m
    mute
    n
    o
    p
    pad*
    pad+
    pad-
    pad.
    pad/
    pad0
    pad1
    pad2
    pad3
    pad4
    pad5
    pad6
    pad7
    pad8
    pad9
    pad=
    padClear
    padEnter
    pageDown
    pageUp
    q
    r
    return
    right
    s
    space
    t
    tab
    u
    up
    v
    w
    x
    y
    z
    [
    ]

