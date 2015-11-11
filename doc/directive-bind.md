# The `bind` Directive #

The `bind` directive follows one of the following formats (tokens may be separated by any number of spaces):

```
bind key:modifiers operation parameter+
bind key:modal-key operation parameter+
```

## `key` ##

`key` is a reference to a key on the keyboard. See [Allowed Keys](keys.md) for a complete list. For example: the `s` key would simply be `s` while the `1` key on the number pad would be `pad1`.

## `modifiers` ##

`modifiers` is a comma or semicolon separated list of standard modifier keys. Allowed modifiers are:

* Control: `ctrl`
* Option/Alt: `alt`
* Command: `cmd`
* Shift: `shift`

**Note:** If you bind `tab:cmd` or `tab:cmd,shift`, Slate will completely disable the default Mac OS X Application switcher!

**Note:** Bindings that are used by Mac OS X spaces, expose, and mission control will override Slate bindings. Be sure to turn these bindings off if you want to use them in Slate.

## `modal-key` ##

`modal-key` is any one of the Allowed Keys. If using a `modal-key`, pressing that key will cause the Slate menu bar icon to change indicating modal mode is activated. then clicking `key` will activate the binding. Modal mode will remain active until `key` has been pressed or `modal-key` is pressed again. You may specify multiple bindings with the same `modal-key` as long as `key` is different. Also, `modal-key` can accompany a comma or semicolon separated list of modifier keys listed above. This will cause that entire keystroke to be considered the modal activation binding. For example: `bind 1:f4,ctrl,alt` will result in the modal keystroke being `ctrl+alt+f4`. After pressing that keystroke, modal mode will be activated and pressing `1` after that will activate the binding.

### Modal Toggle Behavior ###

If you add `:toggle` to the end of a modal binding it will cause that binding to not end the modal mode. For example with the binding `1:ctrl,f4`, you press `ctrl+f4` and then press `1` to activate the binding. Once that binding is activated, modal mode will end and you have to press `ctrl+f4` again to activate it. However, with the binding `1:ctrl,f4:toggle` pressing `ctrl+f4` will toggle modal mode. pressing `1` will activate the binding but not end modal mode. To end modal mode, press `ctrl+f4` again or use the config `modalEscapeKey`.

## `operation` ##

Operations define what to actually do to the focused window.

### Screens ###

Some operations allow you to specify a screen. Here are the list of possible values for screen:

* Integer representing the screen ID (indexed at 0). Screens are ordered from left to right (by X coordinate of the origin which is the top-left point). If `orderScreensLeftToRight` is set to false, the screen ID is the Mac OS internal ID (indexed at 0). If `orderScreensLeftToRight` is set to false but you still want to reference screens in the default ordered mode, prefix the screen ID with `ordered:`.
* Screen resolution in the format `WIDTHxHEIGHT` (e.g. `1440x900`)
* Screen direction relative to the current screen (`left|right|up|above|down|below`)
* `next` or `previous` (represents the `currentID+1` or `currentID-1` screen)

### Operations ###

#### `move`: move/resize the window any which way ####

```
move topLeftX;topLeftY sizeX;sizeY screen
```

* `topLeftX` is the top left x coordinate of the window's desired position (can be an expression)
* `topLeftY` is the top left y coordinate of the window's desired position (can be an expression)
* `sizeX` is the width of the window's desired position (can be an expression)
* `sizeY` is the height of the window's desired position (can be an expression)
* `screen` (optional) is the reference to the screen of the window's desired position. If this is not specified, it will default to the screen the window is currently on. See the table at the beginning of the Operation section for more information.

Example:

```
bind pad1:ctrl move 0;0 100;100 1
```

Will bind the keystroke ctrl-numpad1 to moving the window to the screen at index `1` with top-left coordinate `0,0` and size `100,100`

**Note:** Remember to offset with `screenOriginX` in your `topLeftX` and `screenOriginY` in your `topLeftY` when using the `screen` option (or when using multiple screens in general) or your move operation will offset from the default origin `(0,0)` which is the origin of screen `0`.

#### `resize`: resize the window, keeping top-left the same ####

```
resize x y anchor
```

* `x` is the amount to resize width either as a percent or a hard value (+10% or -100)
* `y` is the amount to resize height either as a percent or a hard value (+10% or -100)
* `anchor` (optional) is which corner to anchor on: `top-left`, `top-right`, `bottom-left`, or `bottom-right`. (Default is `top-left`.)

Example:

```
bind right:ctrl resize +10% +0
```

Will bind the keystroke ctrl-rightarrow to increase the width the current window by `10%`.

**Note:** ctrl-rightarrow is used by default in Mac OS X by spaces. Be sure to turn these bindings off if you want to use them in Slate.

#### `push`: push the window to the edge of the screen ####

```
push direction style
```

* `direction` is `top`, `up`, `bottom`, `down`, `left`, or `right`.
* `style` (optional) is `none`, `center`, `bar`, or `bar-resize:expression`. (Default is `none`.)
* `screen` (optional) is the reference to the screen of the window's desired position. If this is not specified, it will default to the screen the window is currently on. See the table at the beginning of the Operation section for more information.

Example:

```
bind up:alt,ctrl push up
```

Will bind the keystroke alt-ctrl-uparrow to push the window so that it is aligned with the top of the screen

#### `nudge`: nudge the window in any direction ####

```
nudge x y
```

* `x` is the amount to nudge x either as a percent or a hard value (e.g. `+10%` or `-100`).
* `y` is the amount to nudge y either as a percent or a hard value (e.g. `+10%` or `-100`).

Example:

```
bind left:ctrl,shift nudge -100 +0
```

Will bind the keystroke ctrl-shift-leftarrow to nudge the window `100` pixels to the left

#### `throw`: throw the window to any screen's origin ####

```
throw screen style
```

* `screen` is the screen you want to throw the window to (0 indexed).
* `style` (optional) is either `resize` or `resize:x-expression;y-expression`. (Default will not resize.)

Example:

```
bind pad1:alt,ctrl throw 1 resize
```

Will bind the keystroke alt-ctrl-numpad1 to throw the window to the 2nd screen and resize it to fit that screen

#### `corner`: move/resize the window into a corner ####

```
corner direction style screen
```

* `direction` is any of `top-left`, `top-right`, `bottom-left`, `bottom-right`.
* `style` (optional) is `resize:x-expression;y-expression`. (Default will not resize.)
* `screen` (optional) is the reference to the screen of the window's desired position. If this is not specified, it will default to the screen the window is currently on. See the table at the beginning of the Operation section for more information.

Example:

```
bind 1:ctrl corner top-left resize:screenSizeX/2;screenSizeY/2
```

Will bind the keystroke ctrl-1 to move the window to the top-left corner and resize it to 1/4 of the screen

#### `shell`: execute a shell command ####

```
shell options 'command'
```

* `command` (required) is the command to run. note that it is a quoted string.
* `options` (optional) is a space separated list of:
    * `wait`: block slate until the shell command exits. Useful when using shell commands in a sequence binding.
    * `path:PATH_NAME`: `PATH_NAME` is the inital working directory to use when starting the command. For example, `path:~/code` would set the inital working directory to `~/code`.

Example:

```
bind 1:ctrl wait path:~/code '/opt/local/bin/mvim'
```

Will bind the keystroke ctrl-1 to run the command `/opt/local/bin/mvim` with the current working directory of `~/code`. Slate will also block until the command is done. Note that you may **not** use the tilda home directory shortcut within the command itself, it is only allowed within the path.

#### `hide`: hide one or more applications ####

```
hide applications
```

* `applications` is a comma separated list of application names. Individual application names must be surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the Application name (no quotes).
    * `current` will apply to the currently focused application.
    * `all` will apply to all open applications. Note that when trying to hide `all` it will not work as intended because OS X will not allow every visible app to be hidden. Hiding `all` will hide all apps but OS X will auto-show one of the apps that were hidden.
    * `all-but:'APP_NAME'` will apply to all open applications except `APP_NAME`. 

Example:

```
bind 1:ctrl hide 'iTerm','Google Chrome'
```

Will bind the keystroke ctrl-1 to hide iTerm and Google Chrome.

#### `show`: show one or more applications ####

```
show applications
```

* `applications` is a comma separated list of application names. Individual application names must be surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the Application name (no quotes).
    * `current` will apply to the currently focused application.
    * `all` will apply to all open applications.
    * `all-but:'APP_NAME'` will apply to all open applications except `APP_NAME`.

Example:

```
bind 1:ctrl show 'iTerm','Google Chrome'
```

Will bind the keystroke ctrl-1 to show (unhide) iTerm and Google Chrome.

#### `toggle`: toggle one or more applications ####

```
toggle applications
```

* `applications` is a comma separated list of application names. Individual application names must be surrounded by quotes. You can also specify `current`, `all`, or `all-but:` for the Application name (no quotes).
    * `current` will apply to the currently focused application.
    * `all` will apply to all open applications. Note that when trying to toggle `all` it will may not work as intended because OS X will not allow every visible app to be hidden. If at any point during the toggling all apps become hidden, OS X will auto-show one of the apps that were hidden.
    * `all-but:'APP_NAME'` will apply to all open applications except `APP_NAME`.

Example:

```
bind 1:ctrl toggle 'iTerm','Google Chrome'
```

Will bind the keystroke ctrl-1 to toggle iTerm and Google Chrome. Toggle meaning if the individual application is currently hidden it will be shown and if it is currently shown it will be hidden.

**Note:** If you specify current in this toggle operation it will not toggle properly because after the current application is hidden, it is no longer the current application anymore.

#### `chain`: chain multiple operations to one binding ####

```
chain opAndParams1 | opAndParams2 ...`
```

* `opAndParamsX` is any operation string except `sequence`, `hint`, and `grid`.

Example:

```
bind 1:ctrl chain push up | push right | push down | push left
```

Will bind the keystroke ctrl-1 to push up on the first press, then push right on the second press, then push down on the third press, the push left on the fourth press and rotate back to pushing up on the fifth press (etc).

#### `sequence`: activate a sequence of operations in one binding ####

```
sequence opAndParams1 separator opAndParams 2 ...
```

* `opAndParamsX` is any of the above operation strings, except `chain` and `grid`. `hint` must be last if present.
* `separator` is `|` or `>`.
    * `|` will cause the next operation to be performed on the window focused at the time of execution of that operation.
    * `>` will cause the next operation to be performed on the window focused at the start of the `>` chain.

Example:

```
bind 1:ctrl sequence focus right > push left | push right
```

Will bind the keystroke ctrl-1 to first focus the window to the right, then push the previously focused window to the left, then push the newly focused window to the right. Obviously Hint will ignore `>` and `|` and just display because it doesn't care which window was focused.

#### `layout`: activate a layout ####

```
layout name
```

* `name` is the name of the layout to activate (set using the layout directive).

Example:

```
bind 1:ctrl layout myLayout
```

Will bind the keystroke ctrl-l to activate the layout called `myLayout`. Note that the layout **must** be created before you bind it.

#### `focus`: focus a window in a direction or from an application ####

```
focus direction|app
```

* `direction` is any of `right`, `left`, `up`, `above`, `down`, `below`, `behind`
* `app` is an app name surrounded by quotes.

Example:

```
bind 1:ctrl focus above
```

Will bind the keystroke ctrl-1 to focus the window Slate finds to be above the currently focused window (from any application). Minimized and hidden windows are ignored. A couple global configuration options set using the `config` directive exist to tweak this. Also, up and above are the same. Down and below are also the same.

```
bind 1:ctrl focus 'iTerm'
```

Will bind the keystroke ctrl-1 to focus the main window of the application iTerm. The main window is the last focused window of that application.

#### `snapshot`: create a snapshot of your current window locations ####

```
snapshot name options
```

* `name` is the name of the snapshot to create (used in delete-snapshot and activate-snapshot)
* `options` (optional) is a semicolon separated list of any of the following options:
    * `save-to-disk` saves the snapshot to disk so Slate will load it when it starts up next.
    * `stack` treats this snapshot as stack so you can use this binding multiple times to push snapshots on the stack.

Example:

```
bind 1:ctrl snapshot theName save-to-disk;stack
```

Will bind the keystroke ctrl-1 to create a snapshot called `theName`, save that snapshot to disk, and treat it as a stack so you can hit the keystroke multiple times to push snapshots onto the stack.

**Note:** There is a menu option to take a snapshot of the current screen configuration.

#### `delete-snapshot`: delete a snapshot ####

```
delete-snapshot name options
```

* `name` is the name of the snapshot to delete.
* `options` (optional) is a semicolon separated list of any of the following options:
    * `all`: if the snapshot is a stack, this will delete all snapshots in the stack. If this option is not specified, the default is to only delete the top snapshot of the stack.

Example:

```
bind 1:ctrl delete-snapshot theName all
```

Will bind the keystroke ctrl-1 to delete the snapshot called `theName` if it exists. This will delete all instances of theName meaning if you have pushed multiple snapshots on the stack, it will completely clear them all.

#### `activate-snapshot`: activate a snapshot ####

```
activate-snapshot name options
```

* `name` is the name of the snapshot to activate.
* `options` (optional) is a semicolon separated list of any of the following options:
    * `delete` will delete the snapshot after activating it. (If the snapshot is a stack, it will pop the top snapshot off and keep the rest.)

Example:

```
bind 1:ctrl activate-snapshot theName delete
```

Will bind the keystroke ctrl-1 to activate the snapshot called `theName` if it exists. This will also delete the snapshot (or pop it off the stack if the snapshot is a stack).

**Note:** There is a menu option to activate the snapshot that you may have created using the menu option.

#### `hint`: show window hints (similar to link hints in Vimium) ####

```
hint characters
```

* `characters` (optional) is a simple string of characters to be used for the hints. each hint consists of one character. if there are more windows than characters then some windows will not get hints. this string can contain any of the single character Allowed Keys. Letters may be upper case or lower case, but both will be bound to the lowercase letter for the hint. Using upper or lower case only changes how they are displayed. The default string of characters is "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".

Example:

```
bind 1:ctrl hint QWERTYUIOP
```

Will bind the keystroke ctrl-1 to show Window Hints using the letters `Q`, `W`, `E`, `R`, `T`, `Y`, `U`, `I`, `O`, and `P`.  This will show an overlay in the top-left corner of every window on screen containing one of those letters. While the overlays are showing, if one of those letters is pressed, the corresponding window will be focused. If there are more than 10 windows, some windows will not get hints. Pressing ESC will dismiss the hints.

**Note:** There are *tons* of config options to tweak this.

#### `grid`: show a grid to one-off resize and move windows ####

```
grid options
```

* `options` is a whitespace separated list of:
    * `padding:INTEGER` is the padding between cells.
    * `screenRef:width,height`: `width` and `height` are integers specifying the width and height of the grid (number of cells, not absolute size). `screenRef` is either the screenID or screen resolution (`width*height`)

Example:

```
bind 1:ctrl grid padding:5 1680x1050:16,9 1050x1680:9,16
```

Will bind the keystroke ctrl-1 to show Grids on each screen. The default width and height are 12. This will set the padding between the cells to be 5. Also, this will change the width and height of the grid on the monitor with the resolution 1680x1050 to 16 and 9 respectively. For the monitor with the resolution 1050x1680, it will set the width to 9 and height to 16. If you have multiple monitors, the Grid that is on the same screen as your mouse pointer will be focused. If you want to use a grid on a different monitor you **must** click it first and then click+drag.

**Note:** There are a bunch of config options to tweak how this looks.

#### `relaunch`: relaunch Slate ####

```
relaunch
```

Example:

```
bind 1:ctrl relaunch
```

Will bind the keystroke ctrl-1 to relaunch Slate. This will also reload the `.slate` file from scratch.

#### `undo`: undo an operation ####

```
undo
```

Example:

```
bind 1:ctrl undo
```

Will bind the keystroke ctrl-1 to undo the last binding that was triggered. By default you can undo up to the last 10 commands. This can be changed using the `undoMaxStackSize` config. Also, you can only undo movement-based operations. Focus-related operations will not undo.

#### `switch`: \[Beta\] a better application switcher ####

```
switch
```

If you bind any binding to cmd-tab or cmd-shift-tab, Slate will completely disable the default Mac OS X Application switcher!

Example:

```
bind tab:cmd switch
```

Will disable the default Mac OS X Application switcher and bind the keystroke cmd-tab to a better application switcher.

**Note:** There are *tons* of config options to tweak this.
