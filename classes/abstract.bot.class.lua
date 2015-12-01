dyinclude("baseobject.lua");
dyinclude("meta-settings/bot.settings.lua");

__WPL = nil; -- Way Point List
__RPL = nil; -- Return Point List

CAbstractBot = class(CBaseObject,
	function(self, ptr)

	end
);

function CAbstractBot:loadLibs()
	--can't be dynamic
	include("libcore.lua");

	dyinclude("settings.lua");
	dyinclude("function.lua");
	dyinclude("addresses.lua");
	--first add thinks which are static
	dyinclude("extension-classe/logger.class.lua");
	dyinclude("classes/skill.class.lua");
	dyinclude("classes/waypoint.class.lua");
	dyinclude("classes/waypointlist.class.lua");
	dyinclude("classes/waypointlist_wander.class.lua");

	dyinclude("extension-classes/player.class.lua");
	dyinclude("extension-classes/camera.class.lua");
	dyinclude("extension-classes/node.class.lua");
	dyinclude("extension-classes/database.class.lua");
	--expose to global state
	database = CDatabase()
	database:load()
	settings.load();
	setStartKey(settings.hotkeys.START_BOT.key);
	setStopKey(settings.hotkeys.STOP_BOT.key);

end
function CAbstractBot:main()
	self:loadLibs()





end
