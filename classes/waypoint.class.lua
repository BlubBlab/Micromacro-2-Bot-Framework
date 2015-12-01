dyinclude("meta-settings/waypoints.settings.lua");

CWaypoint = class(
	function (self, _X, _Z, _Y)
		-- If we're copying from a waypoint
		if( type(_X) == "table" ) then
			local copyfrom = _X;
			self.X = copyfrom.X;
			self.Z = copyfrom.Z;
			self.Y = copyfrom.Y;
			self.Action = copyfrom.Action;
			self.Type = copyfrom.Type;
			self.Tag = copyfrom.Tag;
			self.Map = copyfrom.Map;
			self.Mounted = copyfrom.Mounted;
			self.Deviation = copyfrom.Deviation;
			self.InAir = copyfrom.InAir;
			self.Id = copyfrom.Id;
			self.RandomFollow = copyfrom.RandomFollow;
			self.RandomBefore = copyfrom.RandomBefore;
			self.NoStop = copyfrom.NoStop;
			self.Zone = copyfrom.Zone;
			self.NoThread = copyfrom.NoThread;
			self.Comments = copyfrom.Comments;
			self.Virtual = copyfrom.Virtual;
		else
			self.X = _X;
			self.Z = _Z;
			self.Y = _Y;
			self.Action = nil; -- String containing Lua code to execute when reacing the point.
			self.Type = WTP_NORMAL;
			self.Tag = "";
			self.Map = nil;
			self.Mounted = nil;
			self.Deviation = nil;
			self.InAir = nil;
			self.Id = nil;
			self.NoStop = nil;
			self.RandomFollow = nil;
			self.RandomBefore = nil;
			self.Zone = nil;
			self.NoThread = nil;
			self.Comments = nil;
			self.Virtual = true;
		end

		if( not self.X ) then self.X = 0.0; end;
		if( not self.Z ) then self.Z = 0.0; end;
	end
);

function CWaypoint:update()
-- Does nothing. Just for compatability with
-- pawn class (so we can interchange if moving
-- to a target, instead)
end
