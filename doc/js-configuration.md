# Slate JavaScript Configuration #

This page documents the JavaScript config feature of Slate. This feature is available in Slate version 1.0.19 and above. It is advised that you update to the latest Slate as some of the APIs may have changed since 1.0.19.

Many thanks to [mgax](https://github.com/mgax) for the initial code.

## Appetizer ##

Normally, the way Slate is configured, a truly dynamic operation is impossible.

For example, lets say I'm a nutjob and I wanted the keystroke `ctrl+1` to:
* if the window's title is "OMG I WANT TO BE FULLSCREEN" then fullscreen the window regardless of the application.
* push the window to the right if the application of the current window is iTerm
* push the window to the left if the application is Google Chrome
* push the window to the top if the application is anything else

And again, I want the keystroke `ctrl+1` to handle all of this. In the typical Slate config, this is impossible.

Enter JavaScript Configs:

```javascript
// Create Operations
var pushRight = slate.operation("push", {
  "direction" : "right",
  "style" : "bar-resize:screenSizeX/3"
});
var pushLeft = slate.operation("push", {
  "direction" : "left",
  "style" : "bar-resize:screenSizeX/3"
});
var pushTop = slate.operation("push", {
  "direction" : "top",
  "style" : "bar-resize:screenSizeY/2"
});
var fullscreen = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX",
  "height" : "screenSizeY"
});
// Bind A Crazy Function to 1+ctrl
slate.bind("1:ctrl", function(win) {
  // here win is a reference to the currently focused window
  if (win.title() === "OMG I WANT TO BE FULLSCREEN") {
    win.doOperation(fullscreen);
    return;
  }
  var appName = win.app().name();
  if (appName === "iTerm") {
    win.doOperation(pushRight);
  } else if (appName === "Google Chrome") {
    win.doOperation(pushLeft);
  } else {
    win.doOperation(pushTop);
  }
});
```

Definitely verbose, but they can do **much** more than normal configs. Yum.

## Main Course ##

**Disclaimer:** This functionality is relatively new and has not been tested extensively. It is definitely possible that some things don't work as expected. Please open an issue if you run into problems.

To use JavaScript configs, create the file `.slate.js` in your home directory. You can use `.slate.js` alongside your `.slate` file if you like and Slate will load both (`.slate` first, then `.slate.js`). You can also use only the `.slate.js` if you want. All JavaScript configs should go into the `.slate.js` file.

In the `.slate.js` file you will have access to the following global objects:
* `slate` - the API to access Slate
* `_` - [Underscore.js](http://underscorejs.org/)

In `.slate.js`, if an exception is thrown, Slate will stop executing and show an alert.

### The `slate` JavaScript Object ###

The `slate` object serves two purposes: configuring Slate and accessing information about the your environment and windows.

The `slate` object is aliased to `S`. For example, instead of calling `slate.log("hi");` you can simply call `S.log("hi");`. Most of the config APIs are aliased as well. See their sections below for their aliases.

### Slate Config APIs ###

#### slate.config ####

```javascript
slate.config(name, value);
```

Set a Slate [global config option](directive-config.md#global-config-options).

* `name` is the name of the Slate config option. Must be a String.
* `value` is the value of the Slate config option. Depending on the config option, it can be a String, Number, Boolean, or Array. If you pass a function, the function will be called and its return value will be used.

**Alias:** `S.config` or `S.cfg`

#### slate.configAll ####

```javascript
slate.configAll({
  name1 : value1,
  name2 : value2,
  // etc.
});
```

Set multiple Slate [global config options](directive-config.md#global-config-options).

* `name` and `value` are the same as `slate.config`.

**Alias:** `S.configAll` or `S.cfga`

#### slate.operation ####

```javascript
var object = slate.operation(name, params);
```

Create a Slate [operation](https://github.com/jigish/slate/wiki/Operations).

* `object` is the created operation. can be used to reference this operation in other APIs.
* `name` is the operation name. must be a String. e.g. `"move"`.
* `params` is the operation's parameters. must be a Hash. more information on the parameters that operations take can be found [here](https://github.com/jigish/slate/wiki/Operations).

**Alias:** `S.operation` or `S.op`

#### slate.operationFromString ####

```javascript
var object = slate.operationFromString(operationString);
```

Create a Slate operation using the [original Slate config style](directive-bind.md#operations).

* `object` - the created operation. can be used to reference this operation in other APIs.
* `operationString` - the original-style Slate config string for the operation. must be a String. e.g. `"push right"`.

**Alias:** `S.operationFromString` or `S.opstr`

#### slate.bind ####

```javascript
slate.bind(keystroke, action, repeat);
```
Bind a [keystroke](keys.md) to an action.

* `keystroke` is the keystroke used to activate this binding. must be a String.
* `action` is the action to perform when this binding is activated. must be an Operation object or a JavaScript function.
* `repeat` indicates whether to repeat this binding if the `keystroke` is held. if `undefined`, the config option `repeatOnHoldOps` will be used to determine if this operation should be repeated. must be `undefined` or a Boolean.

**Alias:** `S.bind` or `S.bnd`

Here is an [explanation of how keystrokes work](https://github.com/jigish/slate/wiki/Keystrokes).

#### slate.bindAll ####

```javascript
slate.bindAll({
  keystroke : action, // this will cause repeat to be undefined
  keystroke : [action, repeat], // or you can just specify repeat like this
  ...
});
```

**Alias:** `S.bindAll` or `S.bnda`

Batch bind [keystrokes](keys.md) to actions.

* `keystroke`, `action` and `repeat` are the same as in `slate.bind`.

#### slate.layout ####

```javascript
var name = slate.layout(name, {
  app : params,
  app : params,
  ...
});
```

Create a Slate [layout](js-layouts.md).

* `name` is the name of the layout. must be a string. used as a reference in other `slate` APIs.
* `app` is the name of the app. must be a string. e.g. `"iTerm"`.
* `params` is the layout parameters. for more information on layout parameters, check [this](js-layouts.md) out.

**Alias:** `S.layout` or `S.lay`

#### slate.default ####

```javascript
slate.default(screenConfig, action);
```

Set a [default action](js-defaults.md) to be performed when a particular screen configuration is seen.

* `screenConfig` is the configuration of screens that will default to `action`. can be an integer (number of screens e.g. `3`) or an Array of Strings (list of resolutions e.g. `["1920x1080","1680x1050","2560x1440"]`).
* `action` is the action to perform when the `screenConfig` is seen. must be a layout name, snapshot name, Operation object or JavaScript function.

**Alias:** `S.default` or `S.def`

#### slate.source ####

```javascript
var success = slate.source(filepath);
```

Load another Slate configuration file.

* `success` - `true` if the file was sourced, `false` if not (an error occurred).
* `filepath` - the complete path to the file to source. can have `"~/"` as a prefix. must be a string.

**Alias:** `S.source` or `S.src`

#### slate.on ####

```javascript
slate.on(event, callback);
```

Listen to an event.

* `event` is the name of the [event](https://github.com/jigish/slate/wiki/Events) to listen for.
* `callback` is the function to execute when the [event](https://github.com/jigish/slate/wiki/Events) occurs.

### Slate Info APIs ###

#### slate.shell ####

```javascript
var output = slate.shell(commandAndArgs, waitForExit, path);
```

Execute a shell command and get the result.

* `output` - the output of the command (on `stdout`). will be nil if `waitForExit` is `false` or `undefined`.
* `commandAndArgs` - the command and args to run. your `.bashrc` or `.bash_profile` will not be sourced before running the command so all binaries need to be referenced by their full path. must be a string. e.g. `"/usr/echo hello"`.
* `waitForExit` - if `true`, Slate will wait for the command to exit and return the output from `stdout`. must be `undefined` or a Boolean.
* `path` - the working directory to use. must be `undefined` or a string. e.g. `"~/"`.

**Alias:** `S.shell` or `S.sh`

#### slate.window ####

```javascript
var windowObject = slate.window();
```

Get the currently focused [window](js-object-window.md).

* `windowObject` is the currently focused [window](js-object-window.md).

**Alias:** `S.window`

#### slate.windowUnderPoint ####

```javascript
var windowObject = slate.windowUnderPoint({
  "x" : xCoord,
  "y" : yCoord
});
```

Get the window under the point specified.

* `xCoord` - the x coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginX+screenSizeX/2"`.
* `yCoord` - the y coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginY+screenSizeY/2"`.

**Alias:** `S.windowUnderPoint` or `S.wup`

#### slate.app ####

```javascript
var appObject = slate.app();
```

Get the currently focused [app](js-object-application.md).

* `appObject` - the currently focused [app](js-object-application.md).

Here is a description of the JavaScript [application object](js-object-application.md).

**Alias:** `S.app`

#### slate.eachApp ####

```javascript
slate.eachApp(function(appObject) {
  // do something with the appObject. this function will run once per running application.
});
```

Cycle through each [app](js-object-application.md).

* `appObject` - the current [app](js-object-application.md) in the loop.

**Alias:** `S.eachApp` or `S.eapp`

#### slate.screen ####

```javascript
var screenObject = slate.screen();
```

Get the currently focused [screen](js-object-screen.md).

* `screenObject` - the currently focused [screen](js-object-screen.md).

**Alias:** `S.screen`

#### slate.screenCount ####

```javascript
var count = slate.screenCount();
```

Get the total number of screens.

* `count` - the total number of screens. will be an integer.

**Alias:** `S.screenCount` or `S.screenc`

#### slate.screenForRef ####

```javascript
var screenObject = slate.screenForRef(reference);
```

Get the [screen object](js-object-screen.md) for the reference.

* `screenObject` - the [screen object](js-object-screen.md) for the reference.
* `reference` - the screen reference. must be a string containing either the id or the resolution. e.g. `"0"` or `"1920x1080"`.

**Alias:** `S.screenForRef` or `S.screenr`

#### slate.screenUnderPoint ####

```javascript
var screenObject = slate.screenUnderPoint({
  "x" : xCoord,
  "y" : yCoord
});
```

Get the screen under the point specified.

* `xCoord` - the x coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginX+screenSizeX/2"`.
* `yCoord` - the y coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginY+screenSizeY/2"`.

**Alias:** `S.screenUnderPoint` or `S.sup`

#### slate.isPointOffScreen ####

```javascript
var result = slate.isPointOffScreen({
  "x" : xCoord,
  "y" : yCoord
});
```

Check whether the given point is off screen or not.

* `result` - `true` if the point is off screen, `false` otherwise.
* `xCoord` - the x coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginX+screenSizeX/2"`.
* `yCoord` - the y coordinate to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginY+screenSizeY/2"`.

**Alias:** `S.isPointOffScreen` or `S.pntoff`

#### slate.isRectOffScreen ####

```javascript
var result = slate.isRectOffScreen({
  "x" : xCoord,
  "y" : yCoord,
  "width" : width,
  "height" : height
});
```

Check whether the given rectangle is off screen or not.

* `result` - `true` if the rectangle is off screen, `false` otherwise.
* `xCoord` - the x coordinate of the top-left point of the rectangle to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginX+screenSizeX/2"`.
* `yCoord` - the y coordinate of the top-left point of the rectangle to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenOriginY+screenSizeY/2"`.
* `width` - the width of the rectangle to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenSizeX/2"`.
* `height` - the height of the rectangle to check. can be an Integer or an [Expression](configuration.md#expressions). e.g. `1337` or `"screenSizeY/2"`.

**Alias:** `S.isRectOffScreen` or `S.rectoff`

#### slate.eachScreen ####

```javascript
slate.eachScreen(function(screenObject) {
  // do something with the screenObject. this function will run once per screen.
});
```

Cycle through each [screen](js-object-screen.md).

* `screenObject` - the current [screen](js-object-screen.md) in the loop.

**Alias:** `S.eachScreen` or `S.escreen`

#### slate.log ####

```javascript
slate.log(message);
```

Log a message to the OS X debug console.

* `message` - the message to log. must be a String.

**Alias:** `S.log`

## Example JavaScript Config ##

Here is my own [`.slate.js`](https://github.com/jigish/dotfiles/blob/master/slate.js).
