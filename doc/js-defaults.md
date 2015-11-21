# Slate JavaScript Configuration: Defaults #

Defaults are used to activate [layouts](js-layouts.md), [snapshots](js-operations.md#snapshot) or run functions when Slate sees a particular screen configuration. Defaults are set using the [`slate.default`](js-configuration.md#slate.default) function. This page describes them in detail.

## Usage ##

### Defaulting a screen configuration to a layout ###

```javascript
slate.default(screenConfig, layoutName);
```

### Defaulting a screen configuration to a snapshot ###

```javascript
slate.default(screenConfig, snapshotName);
```

### Defaulting a screen configuration to a function ###

```javascript
slate.default(screenConfig, function() {
  // do something
});
```

## Description

### Screen Configurations ###

Screen configurations come in two forms: a string containing the number of screens or an array containing a list of screen resolutions.

##### Count ####

```
"3"
```

This describes any screen configuration with exactly 3 monitors.

##### Resolutions ####

```
["1680x1050","2560x1440"]
```

This describes any screen configuration with exactly 2 monitors with the resolutions `"1680x1050"` and `"2560x1440"`

### Layouts ###

See: [Slate JavaScript Configuration: Layouts](js-layouts.md).

### Snapshots ###

Simply call default with a screen configuration and the snapshot name to activate when Slate sees it.

Example:

```
// Create the snapshot
var snapshotName = "omgSnapshotsAreCool";
slate.operation("snapshot", { "name" : snapshotName });

// Default the snapshot to activate when Slate sees 2 mointors
slate.default("2", snapshotName);
```

### Functions ###

Simply call default with a screen configuration and a function to be run when Slate sees it.

Example:

```
// Default the function to run when Slate sees 2 mointors with the resolutions
// "1680x1050" and "2560x1440".
slate.default(["1680x1050","2560x1440"], function() {
  // Cycle through each app
  // (you don't have to do this, you can do anything you really want)
  slate.eachApp(function(appObject) {
    // Cycle through each window within the app
    appObject.eachWindow(function(windowObject) {
      // Push the window to the right.
      // Obviously you can do whatever you want with the window object here.
      windowObject.doOperation(slate.operation("push", { "direction" : "right" });
    });
  });
});
```
