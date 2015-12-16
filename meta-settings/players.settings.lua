players = {};
players.settings = {};

players.settings["craft_list"] = {"CRAFT_BLACKSMITHING","CRAFT_CARPENTRY","CRAFT_ARMORCRAFTING",
	"CRAFT_TAILORING","CRAFT_COOKING","CRAFT_ALCHEMY",
	"CRAFT_MINING","CRAFT_WOODCUTTING","CRAFT_HERBALISM"};
players.settings["craft_types"] = {CRAFT_BLACKSMITHING = 0,CRAFT_CARPENTRY = 1,CRAFT_ARMORCRAFTING = 2,
	CRAFT_TAILORING = 3,CRAFT_COOKING = 4,CRAFT_ALCHEMY = 5,
	CRAFT_MINING = 6,CRAFT_WOODCUTTING = 7,CRAFT_HERBALISM = 8};

players.funcs["player_eval_id"] = function(tmpId)
	if not tmpId or tmpId < PLAYERID_MIN or tmpId > PLAYERID_MAX then
		-- invalid address
		return true
	end
	return false;
end


WF_NONE = 0;   -- We didn't fail
WF_TARGET = 1; -- Failed waypoint because we have a target
WF_DIST = 2;   -- Broke because our distance somehow increased. It happens.
WF_STUCK = 3;  -- Failed waypoint because we are stuck on something.
WF_COMBAT = 4; -- stopped waypoint because we are in combat
WF_PULLBACK = 5; -- Failed because pulled back to before last waypoint


ONLY_FRIENDLY = true;	-- only cast friendly spells HEAL / HOT / BUFF
JUMP_FALSE = false		-- don't jump to break cast
JUMP_TRUE = true		-- jump to break cast





--[[ REDO it as table 


-- The craft numbers correspond with their order in memory


CRAFT_BLACKSMITHING = 0


CRAFT_CARPENTRY = 1


CRAFT_ARMORCRAFTING = 2


CRAFT_TAILORING = 3


CRAFT_COOKING = 4


CRAFT_ALCHEMY = 5


CRAFT_MINING = 6


CRAFT_WOODCUTTING = 7


CRAFT_HERBALISM = 8


]]--
