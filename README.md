# dmc-utils

Small helper functions for Solar2D (formerly Corona SDK) apps: an audio channel with its volume set, an iOS check, the status bar, plus every function of [lua-utils](https://github.com/dmccuskey/lua-utils) for tables, strings, URLs, callbacks, time and image scaling.

dmc-utils is lua-utils packaged like the other DMC Solar2D libraries, with a few Solar2D functions added. `require` returns one table that holds both:

```lua
local Utils = require 'dmc_corona.dmc_utils'

local channel = Utils.getAudioChannel{ volume=0.5 }    -- Solar2D
local parts = Utils.split( 'red,green,blue', ',' )       -- lua-utils
```

## Features

- Audio: find a free channel and set its volume in one call
- Device: is the app running on iOS; show or hide the status bar
- Everything in lua-utils: deep copy and merge, slices, split, URL encoding and query strings, method callbacks, time breakdowns, image scaling
- Pure Lua, no plugins needed; MIT licensed

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It uses the Solar2D functions, then shows a lua-utils time breakdown on the screen.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-utils.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-utils and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Use It

Create `main.lua` in the project folder:

```lua
local Utils = require 'dmc_corona.dmc_utils'

-- the Solar2D functions

print( 'on iOS:', Utils.is_iOS() )
Utils.setStatusBar( 'hide' )

local channel = Utils.getAudioChannel{ volume=0.5 }
print( 'channel', channel, 'volume', audio.getVolume{ channel=channel } )

-- the lua-utils functions, on the same table

local t = Utils.calcTimeBreakdown( 93784 )
local label = t.days .. 'd ' .. t.hours .. 'h ' .. t.minutes .. 'm ' .. t.seconds .. 's'
print( label )

display.newText( label, display.contentCenterX, display.contentCenterY, native.systemFont, 32 )
```

Open the project in the Simulator. The screen shows `1d 2h 3m 4s`; with an iPhone skin, the console shows:

```text
on iOS:	true
channel	1	volume	0.5
1d 2h 3m 4s
```

With an Android skin, `on iOS:` is `false`. If the console shows `module 'dmc_corona.dmc_utils' not found` instead, `dmc_corona/` is missing from the root of the project folder.

`setStatusBar()` hid the status bar of the skin. `getAudioChannel()` found channel 1 free and set its volume, ready for `audio.play( sound, { channel=channel } )`. `calcTimeBreakdown()` comes from lua-utils: 93784 seconds is 1 day, 2 hours, 3 minutes and 4 seconds.

**Going further:** every lua-utils function ([Functions](https://github.com/dmccuskey/lua-utils#functions)).

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Functions

The functions dmc-utils adds, called on the module (`Utils.name( ... )`). The rest are lua-utils', documented in its [Functions](https://github.com/dmccuskey/lua-utils#functions).

| function | does |
|---|---|
| `getAudioChannel( [opts] )` | Returns a free audio channel, from `audio.findFreeChannel( opts.channel )`, after setting its volume to `opts.volume`. Defaults: `channel=1` (the first channel to search from), `volume=1.0`; `opts` is left as it is. When every channel is busy, returns `0` and sets no volume (the volume of channel `0` is that of every channel). |
| `is_iOS()` | `true` if `system.getInfo( 'platform' )` is `'ios'`: iPhone and iPad, and the iOS skins in the Simulator. Apple TV is `'tvos'`, not iOS. |
| `checkIsiPhone5()` | Deprecated, kept for old code: `true` on iOS when `display.pixelHeight` is over 960. From 2012, every current iPhone and iPad passes. |
| `setStatusBar( state, [params] )` | `'show'` or `'hide'` the status bar, on every platform (those without one ignore it). Shows it as `params.type`, default `STATUS_BAR_DEFAULT`. Errors on any other `state`. |
| `setStatusBarDefault( [status] )` | Sets `STATUS_BAR_DEFAULT`, the status bar `setStatusBar( 'show' )` uses (default: `display.DefaultStatusBar`). |
| `STATUS_BAR_DEFAULT`, `STATUS_BAR_HIDDEN`, `STATUS_BAR_TRANSLUCENT`, `STATUS_BAR_DARK` | Solar2D's status bar values (`display.DefaultStatusBar`, ...). |
| `VERSION` | dmc-utils' version, e.g. `'1.3.0'`. |

## Configuration

dmc-utils has no settings: `dmc_corona.cfg` needs no `[DMC_UTILS]` section, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

None in dmc-utils' own functions. The bugs of the lua-utils functions are in its [Known Issues](https://github.com/dmccuskey/lua-utils#known-issues).

## Development

Only `dmc_corona/dmc_utils.lua` and `tests/` are written in this repository. `dmc_utils.lua` loads the DMC boot loader and returns a copy of lua-utils' module from `lib.dmc_lua.lua_utils`, with its own functions and `VERSION` added; the shared module is left as it is. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-utils](https://github.com/dmccuskey/lua-utils), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

The build copies all of DMC-Lua-Library, not only lua-utils.

The unit tests check the wrapper and the Solar2D functions, against stand-ins for `audio`, `display` and `system`; lua-utils' own specs are in its repository. They run under plain Lua 5.1 with dkjson. From the repository's root folder:

```sh
tests/run_unit.sh
```

The Quick Start is the check that the package works in Solar2D.

## License

dmc-utils is released under the [MIT License](LICENSE).
