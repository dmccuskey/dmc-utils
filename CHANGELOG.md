# Changelog

## 1.3.0 (2026-09-30)

### Changed

- `require 'dmc_corona.dmc_utils'` returns a copy of lua-utils' module with the Solar2D functions added, so the shared `lib.dmc_lua.lua_utils`, which other DMC libraries use, is left as it is.
- `setStatusBar()` works on every platform, not only iOS; it leaves `params` as it is.
- `is_iOS()` checks `system.getInfo( 'platform' )` instead of the model name.
- `getAudioChannel()` leaves `opts` as it is. When every channel is busy, it returns `0` without setting a volume (it set the volume of every channel).
- `checkIsiPhone5()` is deprecated, and its two unused parameters are gone.
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION` in the table the module returns.
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 1.2.0

- Earlier releases: see the git history.
