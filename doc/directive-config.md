# The `config` Directive #

The `config` directive follows the following format:

```
config name value
```

Example:

```
config defaultToCurrentScreen true
```

**Note:** the `.slate` file is read top-down directives that come before `config` directives may not have the `config` applied. As such, it is best to put `config` directives at the top of your `.slate` file.

## Config Options ##

The following descriptions are for the JavaScript configs. If you are using the original style configs, all configs that can be arrays should use the String version (semicolon separated string). Also, when using the original style config, double-quotes should not be used for strings.

### Global Config Options ###

#### <a name="defaultToCurrentScreen"/>`defaultToCurrentScreen` ####
- **type:** Boolean
- **default:** `false`
- `true` causes all bindings to default to the current screen if the screen the reference does not exist. `false` causes only bindings that do not specify a screen to default to the current screen while bindings that reference screens that do not exist simply do nothing.

#### <a name="repeatOnHoldOps"/>`repeatOnHoldOps` ####
- **type:** String
- **default:** `"resize,nudge"`
- Comma separated list of operations that should repeat when the hotkey is held.

#### <a name="secondsBeforeRepeat"/>`secondsBeforeRepeat` ####
- **type:** Number
- **default:** `0.4`
- The number of seconds before repeating starts (for ops in `repeatOnHoldOps`)

#### <a name="secondsBetweenRepeat"/>`secondsBetweenRepeat` ####
- **type:** Number
- **default:** `0.1`
- The number of seconds between repeats (for ops in `repeatOnHoldOps`)

#### <a name="checkDefaultsOnLoad"/>`checkDefaultsOnLoad` ####
- **type:** Boolean
- **default:** `false`
- `true` causes the default directives to be checked/triggered after any configuration load.

#### <a name="orderScreensLeftToRight"/>`orderScreensLeftToRight` ####
- **type:** Boolean
- **default:** `true`
- When this is `true`, monitors will be ordered from left to right by X coordinate (if two X coordinates are the same, then the lowest Y coordinate will be first). When this is `false`, screens will be ordered according to the internal Mac OS X ordering which changes depending on which screen was plugged in first. If this is `false`, you can force ordering of screens by prefixing the screen ID with `ordered:`.

#### <a name="keyboardLayout"/>`keyboardLayout` ####
- **type:** String. Must be one of `"dvorak"`, `"colemak"`, `"azerty"` or `"qwerty"`.
- **default:** `"qwerty"`
- The keyboard layout you are using.

#### <a name="modalEscapeKey"/>`modalEscapeKey` ####
- **type:** String
- **default:** `""` (empty string)
- This is the keystroke that will end modal mode (in addition to the keystroke that started modal mode itself). For example setting this to `esc` will allow you to press `esc` after entering modal mode to exit modal mode. You may specify an entire keystroke with modifiers here e.g. `esc:ctrl`.

### Operation-Specific Config Options ###

#### <a name="nudgePercentOf"/>`nudgePercentOf` ####
- **type:** String
- **default:** `screenSize`
- Will use this value for the nudge percent calculation. Possible values are `windowSize` and `screenSize`.

#### <a name="resizePercentOf"/>`resizePercentOf` ####
- **type:** String
- **default:** `screenSize`
- Will use this value for the resize percent calculation. Possible values are `windowSize` and `screenSize`.

#### <a name="focusCheckWidth"/>`focusCheckWidth` ####
- **type:** Integer
- **default:** `100`
- The width (in pixels) of the rectangle used to check directions in the focus directive. Only used for right, left, up, above, down, and below directions. The larger this is, the further away focus will check for adjacent windows. Consequently, the larger this is, the more irritatingly stupid focus can be.

#### <a name="focusCheckWidthMax"/>`focusCheckWidthMax` ####
- **type:** Integer
- **default:** `100`
- If set to anything above focusCheckWidth, the focus option will keep expanding the rectangle used to check directions by focusCheckWidth if it does not find a window until it either finds a window or the width of the rectangle is greater than `focusCheckWidthMax`.

#### <a name="focusPreferSameApp"/>`focusPreferSameApp` ####
- **type:** Boolean
- **default:** `true`
- When this is `true`, the focus operation will *always* choose a window in the same app to focus if it exists in the check width regardless of intersection size. When this is `false`, focus will treat all application windows the same and choose the largest intersection size.

#### <a name="windowHintsBackgroundColor"/>`windowHintsBackgroundColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"50;53;58;0.9"` (same as `[50, 53, 58, 0.9]`)
- The background color for Window Hints as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="windowHintsWidth"/>`windowHintsWidth` ####
- **type:** [Expression](configuration.md#expressions)
- **default:** `"100"`
- The width of the Window Hints overlay in pixels. Please see [this page](configuration.md#expressions) for more information on expressions.

#### <a name="windowHintsHeight"/>`windowHintsHeight` ####
- **type:** [Expression](configuration.md#expressions)
- **default:** `"100"`
- The height of the Window Hints overlay in pixels. Please see [this page](configuration.md#expressions) for more information on expressions.

#### <a name="windowHintsFontColor"/>`windowHintsFontColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"255;255;255;1.0"` (same as `[255, 255, 255, 1.0]`)
- The font color for Window Hints as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="windowHintsFontName"/>`windowHintsFontName` ####
- **type:** String
- **default:** `"Helvetica"`
- The name of the Window Hints font.

#### <a name="windowHintsFontSize"/>`windowHintsFontSize` ####
- **type:** Integer
- **default:** `40`
- The size of the Window Hints font.

#### <a name="windowHintsDuration"/>`windowHintsDuration` ####
- **type:** Number
- **default:** `3`
- The number of seconds that Window Hints will display for.

#### <a name="windowHintsRoundedCornerSize"/>`windowHintsRoundedCornerSize` ####
- **type:** Integer
- **default:** `5`
- The size of the rounded corners of the Window Hints. Set this to `0` if you do not want rounded corners.

#### <a name="windowHintsIgnoreHiddenWindows"/>`windowHintsIgnoreHiddenWindows` ####
- **type:** Boolean
- **default:** `true`
- If this is set to `true`, window hints will not show for windows that are hidden. Hints will show for all windows if this is `false`. A window is hidden if the window under the point at the center of where the hint overlay would show is not the window in question.

#### <a name="windowHintsTopLeftX"/>`windowHintsTopLeftX` ####
- **type:** String with Semicolon Separated Array of [Expressions](configuration.md#expressions)
- **default:** `"(windowSizeX/2)-(windowHintsWidth/2);0"`
- The X offset for window hints from the window's top left point (right is positive, left is negative). If `windowHintsIgnoreHiddenWindows` is set to `true`, the `hint` operation will try each expression in this array (using the Y coordinate from the same index in `windowHintsTopLeftY`) sequentially to see if it represents a point that is visible. The `hint` operation will display a hint at the first visible point. Note that the number of elements in this array *must* equal the number of elements in `windowHintsTopLeftY` or all `hint` bindings will fail validation.

#### <a name="windowHintsTopLeftY"/>`windowHintsTopLeftY` ####
- **type:** String with Semicolon Separated Array of [Expressions](configuration.md#expressions)
- **default:** `"(windowSizeY/2)-(windowHintsHeight/2);0"`
- The Y offset for window hints from the window's top left point (down is positive, up is negative). If `windowHintsIgnoreHiddenWindows` is set to `true`, the `hint` operation will try each expression in this array (using the X coordinate from the same index in `windowHintsTopLeftX`) sequentially to see if it represents a point that is visible. The `hint` operation will display a hint at the first visible point. Note that the number of elements in this array *must* equal the number of elements in `windowHintsTopLeftX` or all `hint` bindings will fail validation.

#### <a name="windowHintsOrder"/>`windowHintsOrder` ####
- **type:** String. Must be one of `"none"`, `"persist"`, `"leftToRight"`, or `"rightToLeft"`.
- **default:** `"leftToRight"`
- Specifies the ordering of windows for Window Hints. If `"none"`, hints will be seemingly randomly ordered. If `"persist"`, hints will be randomly ordered but will remain the same throughout the life of the window (Currently does not work if windows have the same title). If `"leftToRight"`, hints will be ordered from the left of the screen to the right of the screen. If `"rightToLeft"`, hints will be ordered from the right of the screen to the left of the screen.

#### <a name="windowHintsShowIcons"/>`windowHintsShowIcons` ####
- **type:** Boolean
- **default:** `false`
- If true, the application's icon will be shown as a background for the letter instead of the rectangle. This is useful if `windowHintsIgnoreHiddenWindows` is false so that you can know which application a hint for a hidden window belongs to.

#### <a name="windowHintsSpread"/>`windowHintsSpread` ####
- **type:** Boolean
- **default:** `false`
- If true, hints in the same place will be spread out vertically. This is useful if `windowHintsIgnoreHiddenWindows` is false so that multiple windows with the same center will have distinct hints.

#### <a name="windowHintsSpreadSearchWidth"/>`windowHintsSpreadSearchWidth` ####
- **type:** Number
- **default:** `40`
- The width in pixels of the search box for hint collisions. Other hints within this box will be spread down.

#### <a name="windowHintsSpreadSearchHeight"/>`windowHintsSpreadSearchHeight` ####
- **type:** Number
- **default:** `40`
- The height in pixels of the search box for hint collisions. Other hints within this box will be spread down.

#### <a name="windowHintsSpreadPadding"/>`windowHintsSpreadPadding` ####
- **type:** Number
- **default:** `20`
- The padding between hint boxes which have been spread downwards.

#### <a name="snapshotTitleMatch"/>`snapshotTitleMatch` ####
- **type:** String. Must be one of `"levenshtein"` or `"sequential"`.
- **default:** `"levenshtein"`
- The algorithm to use when determining if titles match or not for the snapshot operation. If `"levenshtein"`, the titles with the lowest levenshtein distance will be matched, if sequential, the titles with the maximum common prefix length will be matched. Note that this will change the algorithm for **all** apps. If you would like to change the algorithm for only one app use `"snapshotTitleMatch:'APP_NAME'"` for example to change the algorithm for only iTerm, use the following: `slate.config("snapshotTitleMatch:'iTerm'", "sequential");`.

#### <a name="snapshotMaxStackSize"/>`snapshotMaxStackSize` ####
- **type:** Integer
- **default:** `0`
- The size of the stack to keep when creating snapshots using the `stack` option. If <= 0, the size of the stack will be unlimited.

#### <a name="gridBackgroundColor"/>`gridBackgroundColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"75;77;81;1.0"` (same `[75, 77, 81, 1.0]`)
- The background color for the `grid` operation as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="gridRoundedCornerSize"/>`gridRoundedCornerSize` ####
- **type:** Number
- **default:** `5`
- The size of the rounded corners of the `grid` operation's background. Set this to `0` if you do not want rounded corners.

#### <a name="gridCellBackgroundColor"/>`gridCellBackgroundColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"75;77;81;1.0"` (same as `[75, 77, 81, 1.0]`)
- The background color for the `grid` operation's cells as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="gridCellSelectedColor"/>`gridCellSelectedColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"75;77;81;1.0"` (same as `[75, 77, 81, 1.0]`)
- The selected color for the `grid` operation's cells as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="gridCellRoundedCornerSize"/>`gridCellRoundedCornerSize` ####
- **type:** Number
- **default:** `5`
- The size of the rounded corners of the `grid` operation's cells. Set this to `0` if you do not want rounded corners.

#### <a name="layoutFocusOnActivate"/>`layoutFocusOnActivate` ####
- **type:** Boolean
- **default:** `false`
- If true, activating a layout will focus all windows touched by the layout. The order in which they will be focused is the order in which the Applications occur in the slate file. Thus, the last Application configured in the slate file will be the foremost application after the layout is triggered. If set to false, activating a layout will not focus any of the windows touched. Thus the foremost application after the layout is triggered will be the foremost application before the layout was triggered.

#### <a name="undoMaxStackSize"/>`undoMaxStackSize` ####
- **type:** Integer
- **default:** `10`
- The size of the stack to keep when creating undo snapshots. If <= 0, the size of the stack will be unlimited. This is effectively the number of times you can use the `undo` binding to undo Slate operations.

#### <a name="undoOps"/>`undoOps` ####
- **type:** String
- **default:** `"activate-snapshot,chain,grid,layout,move,push,nudge,corner,throw,resize,sequence,shell"`
- The list of undoable operations. Any operation in this list will take a snapshot before activation to allow undoing it. This may decrease performance. Snapshots will only be taken if an undo operation exists in your config.

#### <a name="switchIconSize"/>`switchIconSize` ####
- **type:** Number
- **default:** `100`
- The size of the application icons for the `switch` operation.

#### <a name="switchIconPadding"/>`switchIconPadding` ####
- **type:** Number
- **default:** `5`
- The padding around the application icons for the `switch` operation.

#### <a name="switchBackgroundColor"/>`switchBackgroundColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"50;53;58;0.3"` (same as `[50, 53, 58, 0.3]`)
- The background color for the `switch` operation as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="switchSelectedBackgroundColor"/>`switchSelectedBackgroundColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"50;53;58;0.9"` (same as `[50, 53, 58, 0.9]`)
- The selected background color for the `switch` operation as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="switchSelectedBorderColor"/>`switchSelectedBorderColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"230;230;230;0.9"` (same as `[230, 230, 230, 0.9]`)
- The selected border color for the `switch` operation as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="switchSelectedBorderSize"/>`switchSelectedBorderSize` ####
- **type:** Number
- **default:** `2`
- The size of the selected border of the `switch` operation. Set this to `0` if you do not a border.

#### <a name="switchRoundedCornerSize"/>`switchRoundedCornerSize` ####
- **type:** Number
- **default:** `5`
- The size of the rounded corners of the `switch` operation. Set this to `0` if you do not want rounded corners.

#### <a name="switchOrientation"/>`switchOrientation` ####
- **type:** String. Must be one of `"horizontal"` or `"vertical"`.
- **default:** `"horizontal"`
- Which direction to grow the application switcher.

#### <a name="switchSecondsBeforeRepeat"/>`switchSecondsBeforeRepeat` ####
- **type:** Number
- **default:** `0.4`
- The number of seconds before repeating starts for forward/back keypresses for the switch operation.

#### <a name="switchSecondsBetweenRepeat"/>`switchSecondsBetweenRepeat` ####
- **type:** Number
- **default:** `0.05`
- The number of seconds between repeating the forward/back keypresses for the switch operation.

#### <a name="switchStopRepeatAtEdge"/>`switchStopRepeatAtEdge` ####
- **type:** Boolean
- **default:** `true`
- If `true`, when holding down the switch operation forward/back keys repeats will trigger until the selected app reaches the end/beginning of the list. If `false`, holding down the switch operation forward/back keys will cycle through the app list without stopping.

#### <a name="switchOnlyFocusMainWindow"/>`switchOnlyFocusMainWindow` ####
- **type:** Boolean
- **default:** `true`
- If `true`, the switch operation will only bring the main window of the selected app forward. If `false`, the switch operation will work similar to the default application switcher and bring all windows of the selected app forward.

#### <a name="switchShowTitles"/>`switchShowTitles` ####
- **type:** Boolean
- **default:** `false`
- If `true`, the switch operation will show the title of the items in the list as well.

#### <a name="switchFontColor"/>`switchFontColor` ####
- **type:** String with Semicolon Separated Array of Floats **or** an Array of Floats
- **default:** `"255;255;255;1.0"` (same as `[255, 255, 255, 1.0]`)
- The font color for the `switch` operation as an array in the form `"Red;Green;Blue;Alpha"` or `[Red, Green, Blue, Alpha]` where `Red`, `Green`, and `Blue` are numbers between `0.0` and `255.0` and `Alpha` is a number between `0.0` and `1.0`.

#### <a name="switchFontName"/>`switchFontName` ####
- **type:** String
- **default:** `"Helvetica"`
- The name of the `switch` operation title font.

#### <a name="switchFontSize"/>`switchFontSize` ####
- **type:** Number
- **default:** `14`
- The size of the `switch` operation font.

#### <a name="switchSelectedPadding"/>`switchSelectedPadding` ####
- **type:** Number
- **default:** `10`
- The size of the padding between the edge of the switch window and the edge of the selected app selected background.
