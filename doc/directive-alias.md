# The `alias` Directive #

The `alias` directive follows the following format:

```
alias name value
```

When you set an alias, you can refer to it in any directive (sequentially after that alias directive) by referencing like `${name}`.

Example:

```
alias bot-right-2nd-mon move screenOriginX+2*screenSizeX/3;screenOriginY+screenSizeY/2 screenSizeX/3;screenSizeY/2 1
```

Will allow you to use `${bot-right-2nd-mon}` as a reference to `move screenOriginX+2*screenSizeX/3;screenOriginY+screenSizeY/2 screenSizeX/3;screenSizeY/2 1` in any directive following the alias (including other alias directives)
