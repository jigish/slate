# Slate #

## About Slate ##

Slate is a window management application similar to Divvy and SizeUp (except better). Originally written to
replace them due to some limitations in how each work, it attemps to overcome them by simply being extremely
configurable.

## Using Slate ##

### Installing Slate ###

build/Release/Slate.app is the packaged application. Simply double-click and it will start running.

### Configuring Slate ###

Slate is configured using a ".slate" file in the current user's home directory. Configuration is split into
two directives: config (for global configurations) and bind (for key bindings).

#### The "config" Directive ####

TODO (unimplemented due to lack of need for global configs as of yet)

#### The "bind" Directive ####

The bind directive follows the following format:

    bind key:modifiers operation parameter+

where key is a reference to a key on the keyboard (see Allowed Keys for the complete list) and modifiers is
a comma separated list of modifier keys. Acceptable modifiers are ctrl, alt, cmd, and shift.

## Contact ##

Please send all bug reports, suggestions, or general commentary to [slate.issues@gmail.com](slate.issues@gmail.com)
