dyinclude("baseobject.lua");
dyinclude("meta-settings/bot.settings.lua");

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
end
function CAbstractBot:main()
	self:loadLibs()


end