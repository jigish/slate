# Slate #

## About Slate ##

Slate is a window management application similar to Divvy and SizeUp (except better). Originally written to
replace them due to some limitations in how each work, it attemps to overcome them by simply being extremely
configurable.

## Using Slate ##

### Installing Slate ###

build/Release/Slate.app is the packaged application. Throw it wherever you want and run it.

### Configuring Slate ###

Slate is configured using a ".slate" file in the current user's home directory. Configuration is loaded upon
running Slate. You can also re-load the config using the "Load Config" menu option on the status menu (use
this at your own risk. It is better to simply restart Slate).

Configuration is split into two directives: config (for global configurations) and bind (for key bindings).

#### The "config" Directive ####

TODO (unimplemented due to lack of need for global configs as of yet)

#### The "bind" Directive ####

The bind directive follows the following format:

    bind key:modifiers operation parameter+

##### Key #####

key is a reference to a key on the keyboard. See Allowed Keys for a complete list. For example: the "s" key
would simply be "s" while the "1" key on the number pad would be "pad1".

##### Modifiers #####

modifiers is a comma separated list of standard modifier keys. Allowed modifiers are:

* Control: "ctrl"
* Option/Alt: "alt"
* Command: "cmd"
* Shift: "shift"

##### Operation #####

Allowed operations are:

* move topLeftX,topLeftY sizeX,sizeY screen

    topLeftX = top left x coordinate of the window's desired position
    topLeftY = top left y coordinate of the window's desired position
    sizeX = width of the window's desired position
    sizeY = height of the window's desired position
    screen = (optional) the id of the screen of the window's desired position (0 indexed). If this is not specified, it will default to the screen the window is currently on

    Example: "bind pad1:ctrl move 0,0 100,100 1" will bind the keystroke ctrl-numpad1 to moving the window to the screen at index 1 with top-left coordinate 0,0 and size 100,100

    You can also use the following values in topLeftX, topLeftY, sizeX or sizeY and they will be replaced with the appropriate values:

        screenOriginX = target screen's top left x coordinate
        screenOriginY = target screen's top left y coordinate
        screenSizeX = target screen's width
        screenSizeY = target screen's height
        windowSizeX = window's width
        windowSizeY = window's height
        windowTopLeftX = window's current top left x coordinate
        windowTopLeftY = window's current top left y coordinate

* resize x y
* push direction
* nudge x y

## Contact ##

Please send all bug reports, suggestions, or general commentary to [slate.issues@gmail.com](slate.issues@gmail.com)

## Appendix A: Allowed Keys ##
