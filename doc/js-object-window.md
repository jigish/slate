# The Slate Window Object #

The Window object is returned by various Slate API functions. This page describes it in detail.

## Description ##

The Window object represents a currently open window.

## Functions ##

### title() ###

Return the title of the window.

```javascript
// win is a window object
var title = win.title();
```

### topLeft() ###

**Alias:** `tl`

Return the top left point that represents this window's location.

```javascript
// win is a window object
var topLeft = win.topLeft();
var topLeftX = topLeft.x;
var topLeftY = topLeft.y;
```

### size() ###

Return the size of this window.

```javascript
// win is a window object
var size = win.size();
var width = size.width;
var height = size.height;
```

### rect() ###

Return the rectangle that represents this window's location and size.

```javascript
// win is a window object
var rect = win.rect();
var topLeftX = rect.x;
var topLeftY = rect.y;
var width = rect.width;
var height = rect.height;
```

### pid() ###

Return the process identifier of the process that owns the window.

```javascript
// win is a window object
var pid = win.pid();
```

### focus() ###

Focus the window. Returns `true` if the focus succeeded, `false` if it did not.

```javascript
// win is a window object
var success = win.focus();
```

### isMinimizedOrHidden() ###

**Alias:** `hidden`

Returns `true` if the window is minimized or hidden, `false` if not.

```javascript
// win is a window object
var isMinimizedOrHidden = win.isMinimizedOrHidden();
```

### isMain() ###

**Alias:** `main`

Returns `true` if the window is the main window of its application, `false` if not.

```javascript
// win is a window object
var isMain = win.isMain();
```

### move() ###

Move the window to a new location. You may use [expressions](js-expressions.md), which will be evaluated based on the screen the window is on or the `"screen"` parameter in the parameter hash. Returns `true` if the move succeeded, `false` if it did not.

```javascript
// win is a window object
var success = win.move({
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "screen" : "0"
});
```

### isMovable() ###

**Alias:** `movable`

Returns `true` if this window can be moved, `false` otherwise.

```javascript
// win is a window object
var isMovable = win.isMovable();
```

### resize() ###

Resize the window. You may use [expressions](js-expressions.md), which will be evaluated based on the screen the window is on or the `"screen"` parameter in the parameter hash. Returns `true` if the resize succeeded, `false` if it did not.

```javascript
// win is a window object
var success = win.resize({
  "width" : "screenSizeX",
  "height" : 500
});
```

### isResizable() ###

**Alias:** `resizable`

Returns `true` if this window can be resized, `false` otherwise.

```javascript
// win is a window object
var isResizable = win.isResizable();
```

### doOperation() ###

**Alias:** `doop`

Perform any [operation](js-operations.md) on the window. Returns `true` if the operation succeeded, `false` if it did not.

```javascript
// win is a window object
var push = slate.operation("push", { "direction" : "up" });
var success = win.doOperation(push);
```

**OR**

```javascript
// win is a window object
var success = win.doOperation("push", { "direction" : "up" });
```

### screen() ###

Return the [screen object](js-object-screen.md) representing the screen this window is on.

```javascript
// win is a window object
var screen = win.screen();
```

### app() ###

Return the [application object](js-object-application.md) representing the application of this window.

```javascript
// win is a window object
var app = win.app();
```
