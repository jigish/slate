# Installing Slate #

**Note:** You must turn on the Accessibility API!

When *Slate* starts it asks you if it can enable access for assistive devices. It may fail to do so. You can manually set this by checking System Preferences > Universal Access > Enable access for assistive devices. If you are on Mavericks or Yosemite, you must turn it on by checking *Slate* in System Preferences > Security & Privacy > Privacy > Accessibility.

## Homebrew Cask ##

If you use [Homebrew Cask](http://caskroom.io/), install the `mattr-slate` cask:

```console
$ brew cask install mattr-slate
```

## Manual Install ##

Get the [latest `Slate.app`](https://github.com/mattr-/slate/releases/latest)  as a _zip_ file.

## Build from Source ##

1. Install XCode.
2. In the terminal, run: `git clone https://github.com/mattr-/slate.git ~/Slate`.
3. Open `~/Slate/Slate.xcodeproj` with XCode.
4. Go to **Product** → **Archive** and wait a minute.
5. Once the Archive Organizer pops up, choose the most recently created Slate export. (It should be selected by default.)
6. Click **Export** (on the right).
7. Select **Export as a Mac Application** and click **Next**.
8. Choose where you want to save Slate.app.
9. Run Slate by opening the Finder to where you saved it and double clicking `Slate.app`.
