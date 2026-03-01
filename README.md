# macOS display layout export/import

Export and import of macOS display arrangement using hammerspoon.

Tested on this setup: 

- Apple M3 Pro (16", Nov. 2023) @ macOS Sequoia 15.6.1 (24G90)
- Hammerspoon 1.1.1 (6936)
- Displays:
  - Internal
  - Dell U2713HM (via display port)
  - Dell U2713HM pivot (via display port + dvi)


## Setup 

### Install [hammerspoon](https://www.hammerspoon.org/)

using [homebrew](https://brew.sh/)

`brew install --cask hammerspoon`  

see https://formulae.brew.sh/cask/hammerspoon#default


### Script

1) Place the `display_layout.lua` file inside your `~/.hammerspoon/` directory

2) In `~/.hammerspoon/init.lua` add these lines:

```lua
require("display_layout")
hs.hotkey.bind({"cmd", "ctrl"}, "E", exportDisplayLayout)
hs.hotkey.bind({"cmd", "ctrl"}, "I", importDisplayLayout)
```

3) Reload hammerspoon config

4) Do what you have to do (see "Usage" below)
5) Disable the lines again. You don't want import/export accidentally.

## Usage

> [!WARNING]
> Does not ask for any confirmation! Be sure before pressing the hotkeys.

Use hotkey `cmd+ctrl+e`to export your display arrangement.
Use hotkey `cmd+ctrl+i`to import your display arrangement.

### When changing displays/connections: 

You may want to go like this do move your display arrangement to a new setup:

1) export => `~/.hammerspoon/display_layout.json`
2) rename exported file to sth like `~/.hammerspoon/display_layout.1.json`
3) change your display setup/connections
4) export again => `~/.hammerspoon/display_layout.json`
5) rename second exported file to sth like `~/.hammerspoon/display_layout.2.json`
6) compare both files and create a new one. Adjust UUIDs/Values as needed
7) save new file as `~/.hammerspoon/display_layout.json`
8) import from the new file


## Auto-reload on change

> [!WARNING]
> Be careful! This may do unexpected things.

```lua
hs.screen.watcher.new(function()
   hs.timer.doAfter(2, importDisplayLayout)
end):start()
```
