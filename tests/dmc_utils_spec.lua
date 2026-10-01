--====================================================================--
-- tests/dmc_utils_spec.lua
--
-- Unit tests for dmc-utils, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-utils has its own specs; these check the wrapper and the
-- Solar2D functions, against stand-ins for audio, display and system
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local Utils, LuaUtils

-- what the stand-ins were called with
local calls

-- the stand-ins' state
local free_channel, platform, pixel_height

function suite_setup()
	_G.audio = {
		findFreeChannel = function( start )
			table.insert( calls, { 'findFreeChannel', start } )
			return free_channel
		end,
		setVolume = function( volume, opts )
			table.insert( calls, { 'setVolume', volume, opts.channel } )
		end,
	}
	_G.display = {
		DefaultStatusBar='default', HiddenStatusBar='hidden',
		TranslucentStatusBar='translucent', DarkStatusBar='dark',
		setStatusBar = function( status )
			table.insert( calls, { 'setStatusBar', status } )
		end,
	}
	system.getInfo = function( key )
		if key == 'platform' then return platform end
	end
	setmetatable( display, { __index=function( t, k )
		if k == 'pixelHeight' then return pixel_height end
	end } )

	Utils = require 'dmc_corona.dmc_utils'
	LuaUtils = require 'lib.dmc_lua.lua_utils'
end

function setup()
	calls = {}
	free_channel, platform, pixel_height = 1, 'ios', 2532
	Utils.setStatusBarDefault()
end



--====================================================================--
--== Tests


function test_module()
	assert_equal( 'table', type( Utils ) )
	assert_equal( '1.3.0', Utils.VERSION )
	assert_equal( 'function', type( Utils.getAudioChannel ) )
	assert_equal( LuaUtils.split, Utils.split )
	assert_equal( 'default', Utils.STATUS_BAR_DEFAULT )
	assert_equal( 'dark', Utils.STATUS_BAR_DARK )
end

function test_shared_module_untouched()
	assert_not_equal( LuaUtils, Utils )
	assert_nil( LuaUtils.VERSION )
	assert_nil( LuaUtils.getAudioChannel )
	assert_nil( LuaUtils.is_iOS )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

function test_audio_channel_defaults()
	assert_equal( 1, Utils.getAudioChannel() )
	assert_equal( 1, calls[1][2] )
	assert_equal( 1.0, calls[2][2] )
	assert_equal( 1, calls[2][3] )
end

function test_audio_channel_options()
	free_channel = 5
	local opts = { volume=0.5, channel=3 }
	assert_equal( 5, Utils.getAudioChannel( opts ) )
	assert_equal( 3, calls[1][2] )
	assert_equal( 0.5, calls[2][2] )
	assert_equal( 5, calls[2][3] )
end

function test_audio_channel_leaves_opts_alone()
	local opts = {}
	Utils.getAudioChannel( opts )
	assert_nil( next( opts ) )
end

function test_audio_channel_none_free()
	free_channel = 0
	assert_equal( 0, Utils.getAudioChannel{ volume=0.2 } )
	assert_equal( 1, #calls )  -- no setVolume() on channel 0
end

function test_is_iOS()
	assert_true( Utils.is_iOS() )
	platform = 'android'
	assert_false( Utils.is_iOS() )
	platform = 'tvos'
	assert_false( Utils.is_iOS() )
end

function test_checkIsiPhone5()
	assert_true( Utils.checkIsiPhone5() )
	pixel_height = 960
	assert_false( Utils.checkIsiPhone5() )
	pixel_height, platform = 2532, 'android'
	assert_false( Utils.checkIsiPhone5() )
end

function test_status_bar_every_platform()
	for _, p in ipairs{ 'ios', 'android', 'macos' } do
		calls, platform = {}, p
		Utils.setStatusBar( 'hide' )
		Utils.setStatusBar( 'show' )
		assert_equal( 'hidden', calls[1][2] )
		assert_equal( 'default', calls[2][2] )
	end
end

function test_status_bar_type()
	local params = {}
	Utils.setStatusBar( 'show', { type='dark' } )
	Utils.setStatusBarDefault( 'translucent' )
	Utils.setStatusBar( 'show', params )
	assert_equal( 'dark', calls[1][2] )
	assert_equal( 'translucent', calls[2][2] )
	assert_nil( params.type )  -- leaves params alone
end

function test_status_bar_unknown_state()
	assert_false( pcall( Utils.setStatusBar, 'off' ) )
	assert_equal( 0, #calls )
end
