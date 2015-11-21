# Slate JavaScript Configuration: Layouts #

Layouts are used to describe a set of operations that run together that you can reference in the [`layout`](js-operations.md#layout) operation and the [`slate.default`](js-configuration.md#slate-default) function. This page describes them in detail.

## Usage ##

Layouts are created using the [`slate.layout`](js-configuration.md#slate-layout) function:

```javascript
var name = slate.layout(name, description);
```

Layouts are used in the [`slate.default`](js-configuration.md#slate-default) function:

```javascript
slate.default(screenConfig, layoutName);
```

This will cause the layout with the name `layoutName` to be activated when Slate sees the screen configuration described by `screenConfig`.

Layouts can also be used in the [`slate.operation`](js-configuration.md#slate-operation) function along with the [`layout`](js-operations.md#layout) operation ###

```javascript
var layoutOperation = slate.operation("layout", {"name": layoutName});
```

This will create an operation that activates the layout with the name `layoutName`.

## Description

When creating layouts using the [`slate.layout`](js-configuration.md#slate-layout) function, two parameters are needed: the `name` of the layout and a hash containing the `description` of the layout.

### `name` ###

The layout name should be a String and cannot be `undefined`. e.g. `"myLayout"`

### `description` ###

The layout description should be a hash (cannot be `undefined`) in the following form:

```javascript
{
  app : params,
  app : params,
  ...
}
```

##### `app` #####

The name of the Application. This must be a String. e.g. `"iTerm"`

You may also specify one of the following special application names:

- `"_before_"` - this specifies what to do before the layout is activated
- `"_after_"` - this specifies what to do after the layout is activated

##### `params` #####

A hash that contains a description of what to do with the Application.

```javascript
{
  "operations" : arrayOfOperationsOrFunctions,
  "ignore-fail" : ignoreFail,
  "repeat" : repeat,
  "repeat-last" : repeatLast,
  "main-first" : mainFirst,
  "main-last" : mainLast,
  "sort-title" : sortTitle,
  "title-order" : titleOrder,
  "title-order-regex" : titleOrderRegex
}
```

- `arrayOfOperationsOrFunctions` - an Array containing any number of [operation](https://github.com/jigish/slate/wiki/Operations) objects and/or functions. These operations or functions will be applied sequentially to windows within the Application starting with the window that was (or is) focused most recently. If an operation fails, the window will be skipped and the operation will be performed on the next window Slate sees within the Application. If there are more windows than there are elements in this array, the windows beyond the number of elements in this array will not have any operations performed on them.
- `ignoreFail` - (optional) if `true`, Slate will move on to the next [operation](https://github.com/jigish/slate/wiki/Operations) or function in `arrayOfOperationsOrFunctions` even if the [operation](https://github.com/jigish/slate/wiki/Operations) failed.
- `repeat` - (optional) if `true`, Slate will repeat the operations in `arrayOfOperationsOrFunctions` until all windows have had an operation performed on them. Does not work with `repeatLast`.
- `repeatLast` - (optional) if `true`, Slate will repeat the last operation in `arrayOfOperationsOrFunctions` until all windows have had an operation performed on them. Does not work with `repeat`
- `main-first` - (optional) if `true`, Slate will reorder the windows such that the main window will have an operation applied on it first. Does not work with `main-last`.
- `main-last` - (optional) if `true`, Slate will reorder the windows such that the main window will have an operation applied on it last. Does not work with `main-first`.
- `sort-title` - (optional) if `true`, Slate will reorder the windows such that they are sorter by title alphabetically increasing.
- `title-order` - (optional) must be `undefined` or an Array of window titles. If this is specified, Slate will start applying operations on windows based on the order specified in the String. Windows with titles not in the String will be after those with titles in the String. Does not work with `title-order-regex`.
- `title-order-regex` - (optional) similar to `title-order` except you may specify a Regular Expression to match the titles against instead of the entire title. Note that once a match is seen, the next Regular Expression will be used to match. This means if you have two windows that match the same Regular Expression, only the first one will be matched. The second will not. Does not work with `title-order`.

**Note:** you may **not** specify any option other than `arrayOfOperationsOrFunctions` when using the special application names `"_before_"` and `"_after_"`.

### Example ###

This example is huge, but it uses all of the possible options so you can see how they are used. Well, all except for `main-last`. I have no use for it but it works very similar to `main-first` (see `Xcode` below).

```javascript
// order screens left to right so they are easier to reference
slate.config("orderScreensLeftToRight", true);

// Set up screen reference variables to avoid typos :)
var leftScreenRef = "0";
var middleScreenRef = "1";
var rightScreenRef = "2";

// Create the various operations used in the layout
var hideSpotify = slate.operation("hide", { "app" : "Spotify" });
var focusITerm = slate.operation("focus", { "app" : "iTerm" });
var leftBottomLeft = slate.operation("move", {
  "screen" : leftScreenRef,
  "x" : "screenOriginX",
  "y" : "screenOriginY+(screenSizeY/2)",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var leftRight = slate.operation("push", {
  "screen" : leftScreenRef,
  "direction" : "right",
  "style" : "bar-resize:screenSizeX/2"
});
var middleTopBar = slate.operation("bar", {
  "screen" : middleScreenRef,
  "direction" : "up",
  "style" : "bar-resize:screenSizeY/2"
});
var middleTopRight = slate.operation("move", {
  "screen" : middleScreenRef,
  "x" : "screenOriginX+(screenSizeX/2)",
  "y" : "screenOriginY",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var middleTopLeft = slate.operation("move", {
  "screen" : middleScreenRef,
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX/2",
  "height" : "screenSizeY/2"
});
var middleBottomRight = slate.operation("move", {
  "screen" : middleScreenRef,
  "x" : "screenOriginX+(2*screenSizeX/3)",
  "y" : "screenOriginY+(screenSizeY/2)",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY/2"
});
var middleBottomMiddle = slate.operation("move", {
  "screen" : middleScreenRef,
  "x" : "screenOriginX+(screenSizeX/3)",
  "y" : "screenOriginY+(screenSizeY/2)",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY/2"
});
var middleBottomLeft = slate.operation("move", {
  "screen" : middleScreenRef,
  "x" : "screenOriginX",
  "y" : "screenOriginY+(screenSizeY/2)",
  "width" : "screenSizeX/3",
  "height" : "screenSizeY/2"
});
var rightChatBar = slate.operation("push", {
  "screen" : rightScreenRef,
  "direction" : "left",
  "style" : "bar-resize:screenSizeX/9"
});
var rightMain = slate.operation("push", {
  "screen" : rightScreenRef,
  "direction" : "right",
  "style" : "bar-resize:8*screenSizeX/9"
});

// Create the layout itself
var threeMonitorsLayout = slate.layout("threeMonitors", {
  "_before_" : { "operations" : hideSpotify }, // before the layout is activated, hide Spotify
  "_after_" : {"operations" : focusITerm }, // after the layout is activated, focus iTerm
  "Adium" : {
    "operations" : [rightChatBar, leftBottomLeft],
    "ignore-fail" : true, // Adium's Contacts window cannot be resized, so the operation rightChatBar will fail.
                          // No big deal, if we ignore the failure Slate will happily move on to leftBottomLeft.
    "title-order" : ["Contacts"], // Make sure the window with the title "Contacts" gets ordered first so that
                                  // we apply the operation rightChatBar to the Contacts window.
    "repeat-last" : true // If I have more that two Adium windows, just use leftBottomLeft on the rest of them.
  },
  "MacVim" : {
    "operations" : [middleTopLeft, middleTopRight],
    "title-order-regex" : ["^\.slate(\.js)?.+$"] // If we see a window whose title matches this regex, order
                                                 // it first. Or in other words, if I'm editing my .slate or
                                                 // .slate.js in MacVim, make sure it uses middleTopLeft.
    "repeat" : true // If I have more than two MacVim windows, keep applying middleTopLeft and middleTopRight.
  },
  "iTerm" : {
    "operations" : [middleBottomLeft, middleBottomMiddle, middleBottomRight],
    "sort-title" : true, // I have my iTerm window titles prefixed with the window number e.g. "1. bash".
                         // Sorting by title ensures that my iTerm windows always end up in the same place.
    "repeat" : true // If I have more than three iTerm windows, keep applying the three operations above.
  },
  "Google Chrome" : {
    "operations" : [function(windowObject) {
      // I want all Google Chrome windows to use the rightMain operation *unless* it is a Developer Tools window.
      // In that case I want it to use the leftRight operation. I can't use title-order-regex here because if it
      // doesn't see the regex, it won't skip the leftRight operation and that will cause one of my other Chrome
      // windows to use it which I don't want. Also, I could have multiple Developer Tools windows which also
      // makes title-order-regex unusable. So instead I just write my own free form operation.
      var title = windowObject.title();
      if (title !== undefined && title.match(/^Developer\sTools\s-\s.+$/)) {
        windowObject.doOperation(leftRight);
      } else {
        windowObject.doOperation(rightMain);
      }
    }],
    "ignore-fail" : true, // Chrome has issues sometimes so I add ignore-fail so that Slate doesn't stop the
                          // layout if Chrome is being stupid.
    "repeat" : true // Keep repeating the function above for all windows in Chrome.
  },
  "Xcode" : {
    "operations" : [middleTopBar, leftRight],
    "main-first" : true, // I want the main window of Xcode to always go to middleTopBar. Any other windows
                         // should use leftRight. So main-first in conjunction with repeat-last is perfect.
    "repeat-last" : true // If I have more than two Xcode windows, keep applying leftRight.
  }
});

// bind the layout to activate when I press Control and the Enter key on the number pad.
slate.bind("padEnter:ctrl", slate.operation("layout", { "name" : threeMonitorsLayout }));

// default the layout so it activates when I plug in my two external monitors.
slate.default(["1920x1080","1680x1050","2560x1440"], threeMonitorsLayout);

// ...

// Profit.
```
