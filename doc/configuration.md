# Configuring Slate #

## Files ##

### Traditional Configuration ###

Slate is configured using a `.slate` file in the current user's home directory. Configuration is loaded upon running Slate. You can also re-load the config using the **Relaunch and Load Config** menu option on the status menu. (Use this at your own risk. It is better to simply restart Slate.)

### JavaScript Configuration ###

**NEW:** You may now use a `.slate.js` file to configure slate using JavaScript. This allows for much more complex and dynamic configurations than the normal slate configuration style below. You can check out the documentation for this [here](https://github.com/jigish/slate/wiki/JavaScript-Configs).

### Default Config File ###

**Note:** If no `.slate` or `.slate.js` file exists in the current user's home directory, the [default config file](Slate/default.slate) will be used.

## Traditional Configuration Format ##

### Directives ###

Configuration is split into the following directives:

* [`config`](directive-config.md) for global configurations
* [`alias`](directive-alias.md) to create alias variables
* [`layout`](directive-layout.md) to configure layouts
* [`default`](directive-default.md) to default certain screen configurations to layouts
* [`bind`](directive-bind.md) for key bindings
* [`source`](directive-source.md) to load configs from another file

**Note:** `#` is the comment character. Anything after a `#` will be ignored.

### Expressions ###

Some directives allow parameters that can be expressions. The following strings will be replaced with the appropriate values when using expressions:

Variable | Description
-------- | -----------
`screenOriginX` | target screen's top left x coordinate (should not be used in Window Hints configs)
`screenOriginY` | target screen's top left y coordinate (should not be used in Window Hints configs)
`screenSizeX` | target screen's width
`screenSizeY` | target screen's height
`windowTopLeftX` | window's current top left x coordinate (should not be used in Window Hints configs)
`windowTopLeftY` | window's current top left y coordinate (should not be used in Window Hints configs)
`windowSizeX` | window's width
`windowSizeY` | window's height
`newWindowSizeX` | window's new width (after resize, only usable in `topLeftX` and `topLeftY`, should not be used in configs)
`newWindowSizeY` | window's new height (after resize, only usable in `topLeftX` and `topLeftY`, should not be used in configs)
`windowHintsWidth` | the value of the windowHintsWidth config (only usable in `windowHintsTopLeftX` and `windowHintsTopLeftY`)
`windowHintsHeight` | the value of the windowHintsHeight config (only usable in `windowHintsTopLeftX` and `dowHintsTopLeftY`)

In addition to the variables above, expressions can be used with the following functions and operators:

Operator/Function | Example
----------------- | -------
`+` | `1+1` ⇒ `2`
`-` | `1-1` ⇒ `0`
`*` | `2*2` ⇒ `4`
`/` | `4/2` ⇒ `2`
`**` | `3**2` ⇒ `9`
`sum` | `sum({1,2,3})` ⇒ `6`
`count` | `count({4,5,6})` ⇒ `3`
`min` | `min({1,3,5})` ⇒ `1`
`max` | `max({1,3,5})` ⇒ `5`
`average` | `average({1,2,3,4})` ⇒ `2.5`
`median` | `median({1,2,3,10,15})` ⇒ `3`
`stddev` | `stddev({1,2,3,4,5})` ⇒ `1.4142135623730951`
`sqrt` | `sqrt(9)` ⇒ `3.0`
`log` | `log(100)` ⇒ `2.0`
`ln` | `ln(8)` ⇒ `2.0794415416798357`
`exp` | `exp(2)` ⇒ `7.3890560989306504` (same as `e**parameter`)
`floor` | `floor(1.9)` ⇒ `1.0`
`ceiling` | `ceiling(1.1)` ⇒ `2.0`
`abs` | `abs(-1)` ⇒ `1`
`trunc` | `trunc(1.1123123123)` ⇒ `1.0`
`random` | `random()` ⇒ `0.20607629744336009` (random float between `0` and `1`)
`randomn` | `randomn(10)` ⇒ `4` (random integer between `0` and `parameter-1`)

**Note:** When using expressions spaces are *not* allowed!

### Example Config ###

You can check out an example config [here](https://github.com/jigish/dotfiles/blob/master/slate).
