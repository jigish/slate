# The Slate Screen Object #

The screen object is returned by various Slate API functions. This page describes it in detail.

## Description ##

The screen object represents a screen. It can be used to reference screens in operations.

## Functions ##

### id() ###

Return the ID of the screen. This can be used to reference the screen in operations.

```javascript
// screen is a screen object
var screenId = screen.id();
```

### rect() ###

Return the rectangle that represents this screen's location and size.

```javascript
// screen is a screen object
var rect = screen.rect();
var topLeftX = rect.x;
var topLeftY = rect.y;
var width = rect.width;
var height = rect.height;
```

### visibleRect() ###

**Alias:** `vrect`

Return the rectangle that represents this screen's visible location and size. This takes the menu bar and dock into account and will return the size and location of the screen without those components.

```javascript
// screen is a screen object
var rect = screen.visibleRect();
var topLeftX = rect.x;
var topLeftY = rect.y;
var width = rect.width;
var height = rect.height;
```

### isMain() ###

**Alias:** `main`

Returns `true` if this screen is the main screen, `false` otherwise.

```javascript
// screen is a screen object
var isMain = screen.isMain();
```
