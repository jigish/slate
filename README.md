# About Slate #

Slate is a window management application similar to Divvy and SizeUp (except better and free!). Originally written to replace them due to some limitations in how each work, it attemps to overcome them by simply being extremely configurable. As a result, it may be a bit daunting to get configured, but once it is done, the benifit is huge.

Slate currently works on Mac OS X 10.6 and above

## Credits ##

Big thanks to [philc](https://github.com/philc) for the Window Hints idea (and initial implementation).

# Using Slate #

## Installing Slate ##

build/Release/Slate.app is the packaged application. Throw it wherever you want and run it.

Note: You must turn on the Accessibility API by checking System Preferences > Universal Access > Enable access for assistive devices

## Configuring Slate ##

Slate is configured using a ".slate" file in the current user's home directory. Configuration is loaded upon running Slate. You can also re-load the config using the "Load Config" menu option on the status menu (use this at your own risk. It is better to simply restart Slate).

Configuration is split into the following directives:

* `config` (for global configurations)
* `alias` (to create alias variables)
* `layout` (to configure layouts)
* `default` (to default certain screen configurations to layouts)
* `bind` (for key bindings)
* `source` (to load configs from another file)

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
    windowHintsWidth = the value of the windowHintsWidth config (only usable in windowHintsTopLeftOffsetX and
                       windowHintsTopLeftOffsetY)
    windowHintsHeight = the value of the windowHintsHeight config (only usable in windowHintsTopLeftOffsetX and
                        windowHintsTopLeftOffsetY)

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
    mode       e.g. mode({1,3,4,3,5}) = 3
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

| Name | Type | Default | Behavior |
|:-----|:-----|:--------|:---------|
| `defaultToCurrentScreen` | Boolean | `false` | `true` causes all bindings to default to the current screen if the screen they reference does not exist. `false` causes only bindings that do not specify a screen to default to the current screen while bindings that reference screens that do not exist simply do nothing. |
| `nudgePercentOf` | String | `windowSize` | Will use this value for the nudge percent calculation. Possible values are `windowSize` and `screenSize`. |
| `resizePercentOf` | String | `windowSize` | Will use this value for the resize percent calculation. Possible values are `windowSize` and `screenSize`. |
| `repeatOnHoldOps` | String | `resize,nudge` | Comma separated list of operations that should repeat when the hotkey is held. |
| `secondsBetweenRepeat` | Number | `0.2` | The number of seconds between repeats (for ops in `repeatOnHoldOps`) |
| `checkDefaultsOnLoad` | Boolean | `false` | `true` causes the default directives to be checked/triggered after any configuration load |
| `focusCheckWidth` | Integer | `100` | The width (in pixels) of the rectangle used to check directions in the focus directive. Only used for right, left, up, above, down, and below directions. The larger this is, the futher away focus will check for adjacent windows. Consequently, the larger this is, the more irritatingly stupid focus can be. |
| `focusCheckWidthMax` | Integer | `100` | If set to anything above focusCheckWidth, the focus option will keep expanding the rectangle used to check directions by focusCheckWidth if it does not find a window until it either finds a window or the width of the rectangle is greater than `focusCheckWidthMax` |
| `focusPreferSameApp` | Boolean | `true` | When this is `true`, the focus operation will *always* choose a window in the same app to focus if it exists in the check width regardless of intersection size. When this is `false`, focus will treat all application windows the same and choose the largest intersection size |
| `orderScreensLeftToRight` | Boolean | `true` | When this is `true`, monitors will be ordered from left to right by X coordinate (if two X coordiates are the same, then the lowest Y coordinate will be first). When this is `false`, screens will be ordered according to the internal Mac OS X ordering which changes depending on which screen was plugged in first. If this is `false`, you can force ordering of screens by prefixing the screen ID with `ordered:` |
| `windowHintsBackgroundColor` | Comma Separated Array of Floats | `50,53,58,0.7` | The background color for Window Hints as an array in the form `Red,Green,Blue,Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `windowHintsWidth` | Expression | `100` | The width of the Window Hints ovelay in pixels. Please see the "Expressions" section above more information on expressions. |
| `windowHintsHeight` | Expression | `100` | The height of the Window Hints overlay in pixels. Please see the "Expressions" section above more information on expressions. |
| `windowHintsFontColor` | Comma Separated Array of Floats | `255,255,255,1.0` | The font color for Window Hints as an array in the form `Red,Green,Blue,Alpha` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0` |
| `windowHintsFontName` | String | `Helvetica` | The name of the Window Hints font |
| `windowHintsFontSize` | Integer | `40` | The size of the Window Hints font |
| `windowHintsDuration` | Number | `3` | The number of seconds that Window Hints will display for |
| `windowHintsRoundedCornerSize` | Integer | `5` | The size of the rounded corner. Set this to `0` if you do not want rounded corners |
| `windowHintsIgnoreHiddenWindows` | Boolean | `true` | If this is set to `true`, window hints will not show for windows that are hidden. Hints will show for all windows if this is `false`. A window is hidden if the window under the point at the center of where the hint overlay would show is not the window in question. |
| `windowHintsTopLeftOffsetX` | Expression | `0` | The X offset for window hints from the window's top left point (right is positive, left is negative) |
| `windowHintsTopLeftOffsetY` | Expression | `0` | The Y offset for window hints from the window's top left point (down is positive, up is negative) |

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
    'app name' = single-quoted name of the application to add to the layout.
    OPTIONS = a comma separated list of options for this application
    operations = a pipe separated list of operations (move, resize, push, nudge, throw, or corner)

Possible Options:

| Name | Function |
|:-----|:---------|
| `IGNORE_FAIL` | This will let slate move to the next operation if the current operation fails to resize/move on the current window |
| `REPEAT` | This will repeat the list of operations if the number of windows is larger than the number of operations |
| `MAIN_FIRST` | This will cause the main window to always use the first operation |
| `MAIN_LAST` | This will cause the main window to always use the last operation (mutally exclusive with `MAIN_FIRST`) |
| `SORT_TITLE` | This will cause the window operations to be triggered on the windows in sorted order by the window title (can be used with `MAIN_FIRST` or `MAIN_LAST`) |
| `TITLE_ORDER=order` | This will cause the operations to be triggered on the windows starting with order which is a semi-colon separated list of window titles |


You can have multiple layout directives that point to the same name in order to link any number of applications to the same layout.

Example:

    layout myLayout 'iTerm' push up bar-resize:screenSizeY/2 | push down bar-resize:screenSizeY/2
    layout myLayout 'Google Chrome' push left bar-resize:screenSizeX/2 | push right bar-resize:screenSizeX/2

Will create a layout called `myLayout` with two operations for iTerm and two operations for Google Chrome. When activated, the first window of iTerm will be moved using the first operation in the first list and the second window of iTerm will be moved using the second operation in the first list. In addition, the first window of Google Chrome will be moved using the first operation in the second list and the second window of Google Chrome will be moved using the second operation in the second list. More information on how to actually use these layouts can be found under the `layout` operation in the `bind` directive section

### The `default` Directive ###

The `default` directive follows the following format (tokens may be separated by any number of spaces):

    default layout-name screen-configuration

Where:

    layout-name = the name of the layout you want to default to
    screen-configuration = either "count:NUMBER_OF_SCREENS" or
                                  "resolutions:SEMICOLON_SEPARATED_LIST_OF_RESOLUTIONS"

This directive will cause any screen configuration change (add monitor, remove monitor, screen resolution change) to trigger a search for a default layout. If the screen configuration matches one of the defaults set, the layout matching `layout-name` will be triggered. For example:

    default myLayout count:2

Will trigger `myLayout` anytime the screen configuration changes to have 2 monitors. Also:

    default myLayout2 resolutions:1440x900;1024x768;1680x1050

Will trigger `myLayout2` anytime the screen configuration changes to have exactly 3 monitors with resolutions `1440x900`, `1024x768`, and `1680x1050`.

### The `bind` Directive ###

The `bind` directive follows the following format (tokens may be separated by any number of spaces):

    bind key:modifiers operation parameter+

#### Key ####

key is a reference to a key on the keyboard. See Allowed Keys for a complete list. For example: the `s` key would simply be `s` while the `1` key on the number pad would be `pad1`.

#### Modifiers ####

modifiers is a comma or semicolon separated list of standard modifier keys. Allowed modifiers are:

* Control: `ctrl`
* Option/Alt: `alt`
* Command: `cmd`
* Shift: `shift`

#### Operation ####

Operations define what to actually do to the focused window.

**Screens**

Some operations allow you to specify a screen. Here are the list of possible values for screen:

* Integer representing the screen ID (indexed at 0). Screens are ordered from left to right (by X coordinate of the origin which is the top-left point). If `orderScreensLeftToRight` is set to false, the screen ID is the Mac OS internal ID (indexed at 0). If `orderScreensLeftToRight` is set to false but you still want to reference screens in the default ordered mode, prefix the screen ID with `ordered:`.
* Screen resolution in the format `WIDTHxHEIGHT` (e.g. `1440x900`)
* Screen direction relative to the current screen (`left|right|up|above|down|below`)
* `next` or `previous` (represents the `currentID+1` or `currentID-1` screen)

**Allowed operations are:**

* Move/Resize the window any which way: `move topLeftX;topLeftY sizeX;sizeY screen`

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

* Resize the window (keeping top-left the same): `resize x y anchor`

        x = amount to resize width either as a percent or a hard value (+10% or -100)
        y = amount to resize height either as a percent or a hard value (+10% or -100)
        anchor = (optional) which corner to anchor on top-left|top-right|bottom-left|bottom-right (default is top-left)

    Example:

        bind right:ctrl resize +10% +0

    Will bind the keystroke ctrl-rightarrow to increase the width the current window by `10%`

* Push the window to the edge of the screen: `push direction style`

        direction = top|up|bottom|down|left|right
        style = (optional) none|center|bar|bar-resize:expression (default is none)
        screen = (optional) the reference to the screen of the window's desired position.
                 If this is not specified, it will default to the screen the window is currently on.
                 See the table at the beginning of the Operation section for more information.

    Example:

        bind up:alt,ctrl push up

    Will bind the keystroke alt-ctrl-uparrow to push the window so that it is aligned with the top of the screen

* Nudge the window in any direction: `nudge x y`

        x = amount to nudge x either as a percent or a hard value (+10% or -100)
        y = amount to nudge y either as a percent or a hard value (+10% or -100)

    Example:

        bind left:ctrl,shift nudge -100 +0

    Will bind the keystroke ctrl-shift-leftarrow to nudge the window `100` pixels to the left

* Throw the window to any screen's origin: `throw screen style`

        screen = the screen you want to throw the window to (0 indexed)
        style = (optional) resize|resize:x-expression;y-expression (default will not resize)

    Example:

        bind pad1:alt,ctrl throw 1 resize

    Will bind the keystroke alt-ctrl-numpad1 to throw the window to the 2nd screen and resize it to fit that screen

* Move/Resize the window into a corner: `corner direction style`

        direction = top-left|top-right|bottom-left|bottom-right
        style = (optional) resize:x-expression;y-expression (default will not resize)
        screen = (optional) the reference to the screen of the window's desired position.
                 If this is not specified, it will default to the screen the window is currently on.
                 See the table at the beginning of the Operation section for more information.

    Example:

        bind 1:ctrl corner top-left resize:screenSizeX/2;screenSizeY/2

    Will bind the keystroke ctrl-1 to move the window to the top-left corner and resize it to 1/4 of the screen

* Chain multiple operations to one binding: `chain opAndParams1 | opAndParams2 ...`

        opAndParamsX = any of the above operation strings

    Example:

        bind 1:ctrl chain push up | push right | push down | push left

    Will bind the keystroke ctrl-1 to push up on the first press, then push right on the second press, then push down on the third press, the push left on the fourth press and rotate back to pushing up on the fifth press (etc).

* Activate a layout: `layout name`

        name = the name of the layout to activate (set using the layout directive)

    Example:

        bind 1:ctrl layout myLayout

    Will bind the keystroke ctrl-l to activate the layout called `myLayout`

* Focus a window from any application in a direction: `focus direction`

        direction = right|left|up|above|down|below|behind

    Example:

        bind 1:ctrl focus above

    Will bind the keystroke ctrl-1 to focus the window Slate finds to be above the currently focused window. (minimized and hidden windows are ignored and a couple global configuration options set using the `config` directive exist to tweak this).

* Create a snapshot of your current window locations: `snapshot name options`

        name = the name of the snapshot to create (used in delete-snapshot and activate-snapshot)
        options = (optional) a semicolon separated list of any of the following options:
          save-to-disk -> saves the snapshot to disk so Slate will load it when it starts up next
          stack -> treats this snapshot as stack so you can use this binding multiple times to push snapshots on the stack

    Example:

         bind 1:ctrl snapshot theName save-to-disk;stack

    Will bind the keystroke ctrl-1 to create a snapshot called `theName`, save that snapshot to disk, and treat it as a stack so you can hit the keystroke multiple times to push snapshots onto the stack.

**Note:** There is a menu option to take a snapshot of the current screen configuration.

* Delete a snapshot: `delete-snapshot name options`

        name = the name of the snapshot to delete
        options = (optional) a semicolon separated list of any of the following options:
          all -> if the snapshot is a stack (if it isn't, this option is useless), this will delete all snapshots in the
                 stack (if this option is not specified, the default is to only delete the top snapshot of the stack).

    Example:

        bind 1:ctrl delete-snapshot theName all

    Will bind the keystroke ctrl-1 to delete the snapshot called `theName` if it exists. This will delete all instances of theName meaning if you have pushed multiple snapshots on the stack, it will completely clear them all.

* Activate a snapshot: `activate-snapshot name options`

        name = the name of the snapshot to delete
        options = (optional) a semicolon separated list of any of the following options:
          delete -> this will delete the snapshot after activating it (if the snapshot is a stack, it will pop the top
                    snapshot off and keep the rest)

    Example:

        bind 1:ctrl activate-snapshot theName delete

    Will bind the keystroke ctrl-1 to activate the snapshot called `theName` if it exists. This will also delete the snapshot (or pop it off the stack if the snapshot is a stack).

**Note:** There is a menu option to activate the snapshot that you may have created using the menu option.

* Show Window Hints (similar to Link Hints in Vimium except for Windows): `hint characters`

        characters = (optional) a simple string of characters to be used for the hints. each hint consists of one
                     character. if there are more windows than characters then some windows will not get hints.
                     this string can contain any of the single character Allowed Keys. Letters may be upper case or
                     lower case, but both will be bound to the lowercase letter for the hint. Using upper or lower
                     case only changes how they are displayed. The default string of characters is
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    Example:

        bind 1:ctrl hint QWERTYUIOP

    Will bind the keystroke ctrl-1 to show Window Hints using the letters `Q`, `W`, `E`, `R`, `T`, `Y`, `U`, `I`, `O`, and `P`.  This will show an overlay in the top-left corner of every window on screen containing one of those letters. While the overlays are showing, if one of those letters is pressed, the corresponding window will be focused. If there are more than 10 windows, some windows will not get hints.

    **Note:** There are *tons* of config options to tweak this.

### The `source` Directive ###

The source directive follows the following format (tokens may be separated by any number of spaces):

    source filename optional:if_exists

Where `filename` is the name of a file containing any of the directives above (including source). If no absolute path is specified, the user's home directory will be prepended to `filename`. If the user specifies the option `if_exists` as the second argument, Slate will not complain if it cannot find the file.

For Example:

    source ~/.slate.test if_exists

Will append all of the configurations from the file `~/.slate.test` to the current configuration if the file `~/.slate.tests` exists.

**Note:** You may use any aliases, layouts, etc that you specify before the source directive in the file you source. Any aliases, layouts, etc specified after cannot be used. Additionally, any aliases, layouts, etc that you specify in the file you source can be used after the source directive.

### Example Config ###

You can check out my own config [here](https://github.com/jigish/dotfiles/blob/master/slate).

# Contact #

Please send all questions, bug reports, suggestions, or general commentary to [Jigish Patel](mailto:slate.issues@gmail.com) or [create an issue](https://github.com/jigish/slate/issues/new) on github.

# Allowed Keys #

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
    fn
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
