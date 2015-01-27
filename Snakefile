# dmc-utils

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-utils"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-utils",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_utils.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-utils", module_config )

