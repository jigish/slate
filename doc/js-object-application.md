# The Slate Application Object #

The application object is returned by various Slate API functions. This page describes it in detail.

## Description ##

The application object represents a currently running application.

## Functions ##

### pid() ###

Return the Process Identifier of the application.

```javascript
// app is an application object
var pid = app.pid();
```

### name() ###

Return the name of the application.

```javascript
// app is an application object
var name = app.name();
```

### eachWindow() ###

**Alias:** `ewindow`

Loop over each [window](js-object-window.md) within the application and run a function for each one.

```javascript
// app is an application object
var name = app.eachWindow(function(windowObject) {
  // do something with windowObject
});
```

* `windowObject` is a [window object](js-object-window.md) representing the current window within the callback function.

### mainWindow() ###

**Alias:** `mwindow`

Return the main [window](js-object-window.md) of the application or `undefined` if there is none.

```javascript
// app is an application object
var mainWindow = app.mainWindow();
```
