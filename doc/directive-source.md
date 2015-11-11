# The `source` Directive #

The source directive follows the following format (tokens may be separated by any number of spaces):

```
source filename optional:if_exists
```

Where `filename` is the name of a file containing any of the directives above (including source). If no absolute path is specified, the user's home directory will be prepended to `filename`. If the user specifies the option `if_exists` as the second argument, Slate will not complain if it cannot find the file.

For Example:

```
source ~/.slate.test if_exists
```

Will append all of the configurations from the file `~/.slate.test` to the current configuration if the file `~/.slate.test` exists.

**Note:** You may use any aliases, layouts, etc that you specify before the source directive in the file you source. Any aliases, layouts, etc specified after cannot be used. Additionally, any aliases, layouts, etc that you specify in the file you source can be used after the source directive.
