# About Slate #

Slate is a window management application similar to Divvy and SizeUp (except better and free!). Originally written to replace them due to some limitations in how each work, it attemps to overcome them by simply being extremely configurable.

# Using Slate #

## Installing Slate ##

build/Release/Slate.app is the packaged application. Throw it wherever you want and run it.

## Configuring Slate ##

Slate is configured using a ".slate" file in the current user's home directory. Configuration is loaded upon running Slate. You can also re-load the config using the "Load Config" menu option on the status menu (use this at your own risk. It is better to simply restart Slate).

Configuration is split into two directives: config (for global configurations) and bind (for key bindings).

### The "config" Directive ###

TODO (unimplemented due to lack of need for global configs as of yet)

### The "bind" Directive ###

The bind directive follows the following format:

    bind key:modifiers operation parameter+

NOTE: The tokens above can only be separated by a single space as of now. More intelligent config parsing to come in a future version. For example, this is allowed:

    bind 1:ctrl push up

is allowed but this is not:

    bind     1:ctrl push            up

#### Key ####

key is a reference to a key on the keyboard. See Allowed Keys for a complete list. For example: the "s" key would simply be "s" while the "1" key on the number pad would be "pad1".

#### Modifiers ####

modifiers is a comma or semicolon separated list of standard modifier keys. Allowed modifiers are:

* Control: "ctrl"
* Option/Alt: "alt"
* Command: "cmd"
* Shift: "shift"

#### Operation ####

Operations define what to actually do to the focused window.

Some operations allow parameters that can be expressions. The following strings will be replaced with the appropriate values when using expressions:

    screenOriginX = target screen's top left x coordinate
    screenOriginY = target screen's top left y coordinate
    screenSizeX = target screen's width
    screenSizeY = target screen's height
    windowSizeX = window's width
    windowSizeY = window's height
    windowTopLeftX = window's current top left x coordinate
    windowTopLeftY = window's current top left y coordinate

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

Note: When using expressions spaces are *not* allowed!

Allowed operations are:

* Move/Resize the window any which way: "move topLeftX;topLeftY sizeX;sizeY screen"

    This is the granddaddy of all the operations. The rest of the operations are all wrapped versions of move.

        topLeftX = top left x coordinate of the window's desired position (can be an expression)
        topLeftY = top left y coordinate of the window's desired position (can be an expression)
        sizeX = width of the window's desired position (can be an expression)
        sizeY = height of the window's desired position (can be an expression)
        screen = (optional) the id of the screen of the window's desired position (0 indexed). If this is not specified, it will default to the screen the window is currently on

    Example:

        bind pad1:ctrl move 0;0 100;100 1

    Will bind the keystroke ctrl-numpad1 to moving the window to the screen at index 1 with top-left coordinate 0,0 and size 100,100

    Remember to offset with screenOriginX in your topLeftX and screenOriginY in your topLeftY when using the "screen" option (or when using multiple monitors in general) or your move operation will offset from the default origin (0,0) which is the origin of screen 0.

* Resize the window (keeping top-left the same): "resize x y anchor"

        x = amount to resize width either as a percent or a hard value (+10% or -100)
        y = amount to resize height either as a percent or a hard value (+10% or -100)
        anchor = (optional) which corner to anchor on top-left|top-right|bottom-left|bottom-right (default is top-left)

    Example:

        bind right:ctrl resize +10% +0

    Will bind the keystroke ctrl-rightarrow to increase the width the current window by 10%

* Push the window to the edge of the screen: "push direction style"

        direction = top|up|bottom|down|left|right
        style = (optional) none|center|bar|bar-resize:expression (default is none)

    Example:

        bind up:alt,ctrl push up

    Will bind the keystroke alt-ctrl-uparrow to push the window so that it is aligned with the top of the screen

* Nudge the window in any direction: "nudge x y"

        x = amount to nudge x either as a percent or a hard value (+10% or -100)
        y = amount to nudge y either as a percent or a hard value (+10% or -100)

    Example:

        bind left:ctrl,shift nudge -100 +0

    Will bind the keystroke ctrl-shift-leftarrow to nudge the window 100 pixels to the left

* Throw the window to any screen's origin: "throw screen style"

        screen = the screen you want to throw the window to (0 indexed)
        style = (optional) resize|resize:x-expression,y-expression (default will not resize)

    Example:

        bind pad1:alt,ctrl throw 1 resize

    Will bind the keystroke alt-ctrl-numpad1 to throw the window to the 2nd screen and resize it to fit that screen

* Move/Resize the window into a corner: "corner direction style"

        direction = top-left|top-right|bottom-left|bottom-right
        style = (optional) resize:x-expression,y-expression (default will not resize)

    Example:

        bind 1:ctrl corner top-left resize:screenSizeX/2;screenSizeY/2

    Will bind the keystroke ctrl-1 to move the window to the top-left corner and resize it to 1/4 of the screen

### Example Config ###

You can check out my own config in the file [here](https://github.com/jigish/dotfiles/blob/master/slate).

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
