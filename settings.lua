settings_default = {
	hotkeys = {
		MOVE_FORWARD = {key = _G.key.VK_W, modifier = nil},
		MOVE_BACKWARD = {key = _G.key.VK_S, modifier = nil},
		ROTATE_LEFT = {key = _G.key.VK_Q, modifier = nil},
		ROTATE_RIGHT = {key = _G.key.VK_E, modifier = nil},
		STRAFF_LEFT = {key = _G.key.VK_A, modifier = nil},
		STRAFF_RIGHT = {key = _G.key.VK_D, modifier = nil},
		JUMP = {key = _G.key.VK_SPACE, modifier = nil},
		TARGET = {key = _G.key.VK_TAB, modifier = nil},
		TARGET_FRIEND = {key = _G.key.J, modifier = nil},
		ESCAPE = {key = _G.key.VK_ESCAPE, modifier = nil},
		START_BOT = {key = _G.key.VK_DELETE, modifier = nil},
		STOP_BOT = {key = _G.key.VK_END, modifier = nil}
	},
	options = {
		ENABLE_FIGHT_SLOW_TURN = false,
		MELEE_DISTANCE = 50,
		LANGUAGE = "english",
		USE_CLIENT_LANGUAGE = true,		-- automatic use client language after loading the bot
		DEBUGGING = false,
		DEBUGGING_MACRO = false,
		ROMDATA_PATH = nil,
		TARGET_FRAME = true,
	},
	profile = {
		options = {
			-- common options
			HP_LOW = 85,
			MP_LOW_POTION = 50,
			HP_LOW_POTION = 40,
			COMBAT_TYPE = "melee",
			COMBAT_RANGED_PULL = "true",	-- only for melee classes , use ranged skill to pull
			COMBAT_DISTANCE = 200,
			ANTI_KS = true,
			WAYPOINTS = "demo.xml",
			RETURNPATH = nil,
			PATH_TYPE = "waypoints",
			WANDER_RADIUS = 500,
			WAYPOINT_DEVIATION = 0,
			LOOT = true,
			LOOT_ALL = false,
			LOOT_IGNORE_LIST_SIZE = 10,
			LOOT_TIME = 1500,
			LOOT_AGAIN = 2000,				-- second loot try if rooted after x ms
			LOOT_IN_COMBAT = true,
			LOOT_DISTANCE = nil,
			LOOT_PAUSE_AFTER = 10,			-- probability in % for short pause after loot to look more human
			HARVEST_DISTANCE = 120,
			HARVEST_WOOD = true,
			HARVEST_HERB = true,
			HARVEST_ORE = true,
			MAX_FIGHT_TIME = 10,
			DOT_PERCENT = 90,
			LOGOUT_TIME = 0,
			LOGOUT_SHUTDOWN = false,
			LOGOUT_WHEN_STUCK = true,
			MAX_UNSTICK_TRIALS = 10,
			TARGET_LEVELDIF_BELOW = 99,
			TARGET_LEVELDIF_ABOVE = 99,
			QUICK_TURN = false,
			MP_REST = 15,
			HP_REST = 15,
			RES_AFTER_DEATH = false,	-- automatic resurrect after death true|false,
			HEALING_POTION = 0,				-- shopping options, how many to buy/have in inventory
			MANA_POTION = 0,				-- shopping options, how many to buy/have in inventory
			ARROW_QUIVER = 0,				-- shopping options, how many to buy/have in inventory
			THROWN_BAG = 0,					-- shopping options, how many to buy/have in inventory
			POISON = 0,						-- shopping options, how many to buy/have in inventory
			EGGPET_HOE = 0,					-- shopping options, how many to buy/have in inventory
			EGGPET_SPADE = 0,				-- shopping options, how many to buy/have in inventory
			EGGPET_HATCHET = 0,				-- shopping options, how many to buy/have in inventory
			RELOAD_AMMUNITION = false,		-- false|arrow|thrown
			EGGPET_ENABLE_CRAFT = false,
			EGGPET_CRAFT_SLOT = nil,
			EGGPET_ENABLE_ASSIST = false,
			EGGPET_ASSIST_SLOT = nil,
			EGGPET_CRAFT_RATIO = "1:1:1",	-- mining:woodworking:herbalism ratio to use when crafting. '0' means do not craft that type.
			EGGPET_CRAFT_INDEXES = ",,",	-- Index level override for mine:wood:herb eg. ",,1" will only create index level 1 herb items


			-- expert options
			MAX_SKILLUSE_NODMG = 4,				-- maximum casts without damaging the target before break it
			MAX_TARGET_DIST = 250,			-- maximum distance to select a target (helpfull to limit at small places)
			AUTO_ELITE_FACTOR = 5,			-- mobs with x * your HP value counts as 'Elite' and we will not target it
			AUTO_TARGET = true,				-- bot will target mobs automaticly (set it to false if you want to use the bot only as fight support)
			--			SKILL_GLOBALCOOLDOWN = 1200,	-- Global Skill Use Cooldown (1000ms) we use a little more
			SKILL_USE_PRIOR = "auto",			-- cast x ms before cooldown is finished
			PK_COUNTS_AS_DEATH = true,		-- count playerkill's as death
			POTION_COOLDOWN = 15,			-- always 15
			POTION_COOLDOWN_HP = 0,			-- will only be used if not 0, if 0 POTION_COOLDOWN will be used
			POTION_COOLDOWN_MANA = 0,		-- will only be used if not 0, if 0 POTION_COOLDOWN will be used
			SIT_WHILE_RESTING = false,		-- sit while using the rest function
			USE_MANA_POTION = "best",		-- which mana potion type to use: best | minstack
			USE_HP_POTION = "best",			-- which HP potion type to use: best | minstack
			WAYPOINTS_REVERSE = false,		-- use the waypoint file in reverse order
			WAYPOINT_PASS = 100,			-- skip a waypoint if we pass in distance x while fighting a mob (go to as melee)
			WAYPOINT_PASS_DEGR = 90,		-- skip a waypoint if we touched one and the next is at least x degrees in front
			MAX_DEATHS = 10,				-- maximal death if automatic resurrect befor logout
			WAIT_TIME_AFTER_RES = 8000,		-- time to wait after resurrection, needs more on slow PCs
			RETURNPATH_SUFFIX = "_return",	-- suffix for default naming of returnpath
			HARVEST_SCAN_WIDTH = 5,			-- steps horizontal
			HARVEST_SCAN_HEIGHT = 5,		-- steps vertical
			HARVEST_SCAN_STEPSIZE = 60,		-- wide of every step
			HARVEST_SCAN_TOPDOWN = false,	-- true = top->down  false = botton->up
			HARVEST_SCAN_XMULTIPLIER = 1.0,	-- multiplier for scan width
			HARVEST_SCAN_YMULTIPLIER = 1.1,	-- multiplier for scan line height
			HARVEST_SCAN_YREST = 10,		-- scanspeed
			HARVEST_SCAN_YMOVE = 1.1,		-- move scan area top/down ( 1=middle of screen )
			HARVEST_TIME = 45,				-- how long we maximum harvest a node
			USE_SLEEP_AFTER_RESUME = false, -- enter sleep mode after pressing pause/resume key
			IGNORE_MACRO_ERROR = false, 	-- ignore missing MACRO hotkey error (only temporary option while beta)
			DEBUG_INV = false,	 			-- to help to find the item use error (only temporary option while beta)
			DEBUG_LOOT = false,	 			-- debug loot issues
			DEBUG_TARGET = false, 			-- debug targeting issues
			DEBUG_HARVEST = false, 			-- debug harvesting issues
			DEBUG_WAYPOINT = false, 		-- debug waypoint issues
			DEBUG_AUTOSELL = false, 		-- debug autosell issues
			DEBUG_SKILLUSE = false,			-- debug skill use issues

			-- expert inventar
			INV_UPDATE_INTERVAL = 300,	 	-- full inventory update every x seconds (only used indirect atm)
			INV_AUTOSELL_ENABLE = false,	-- autosell items at merchant true|false
			INV_AUTOSELL_FROMSLOT = 0,		-- autosell from slot #
			INV_AUTOSELL_TOSLOT = 0,		-- autosell to slot #
			INV_AUTOSELL_QUALITY = "white",	-- itemcolors to sell
			INV_AUTOSELL_IGNORE = nil,		-- itemnames never so sell
			INV_AUTOSELL_NOSELL_DURA = 0,	-- durability > x will not sell, 0=sell all
			INV_AUTOSELL_STATS_NOSELL = nil,	-- stats (text search at right tooltip side) that will not be selled
			INV_AUTOSELL_STATS_SELL = nil,		-- stats (text search at right tooltip side) that will be selled, even if in nosell
			INV_AUTOSELL_NOSELL_STATSNUMBER = 3,-- If the item has this many or more named stats then don't sell


		},
		hotkeys = {  },
		skills = nil,
		skillsData = {},
		friends = {},
		mobs = {},
		events = {
			onDeath = nil,
			onLoad = nil,
			onLeaveCombat = nil,
			onPreSkillCast = nil,
			onSkillCast = nil,
			onLevelup = nil,
			onHarvest = nil,
			onUnstickFailure = nil,
		}
	},
};

bot =	{ 		-- global bot values
	ClientLanguage,		-- ingame language of the game [ DE|RU|FR|ENUS|ENEU
	GetTimeFrequency,	-- calculated CPU frequency for calculating with the getTime() function
	LastSkillKeypressTime = getTime(),	-- remember last time we cast (press key)
	IgfAddon = false,	-- check if igf addon is active
	IgfVersion = 11;
	S = false;
	UseAutoUpdateSkills = false;
	Gamedirectory = "Runes of Magic";
	Keybindfile = "bindings.txt";
};


if( table.copy == nil ) then
	table.copy = function (_other)
		local t = {};
		for i,v in pairs(_other) do
			if type(v) == "table" then
				t[i] = table.copy(v)
			else
				t[i] = v;
			end
		end
		return t;
	end
end

settings = table.copy(settings_default);

check_keys = { name = { } };

--SKILLUSES_HP = 1 -- Not used by bot
SKILLUSES_MANA = 2
--SKILLUSES_HPPER = 3 -- Not used by bot
--SKILLUSES_MPPER = 4 -- Not used by bot
SKILLUSES_RAGE = 5
SKILLUSES_FOCUS = 6
SKILLUSES_ENERGY = 7
SKILLUSES_ITEM = 9
SKILLUSES_PROJECTILE = 13
SKILLUSES_ARROW = 14
SKILLUSES_PSI = 15
PLAYERID_MIN = 1000
PLAYERID_MAX = 1005


























