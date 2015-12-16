include("waypoint.class.lua");
dyinclude("meta-settings/waypointlists.settings.lua");

-- check if we in test mode
if( not player and not waypointlists.settings.test)then
	error("No player object found in waypointlist");
end

CWaypointList = class(
	function(self)
		self.Waypoints = {};
		self.CurrentWaypoint = 1;
		self.LastWaypoint = 1;
		self.Direction = WPT_FORWARD;
		-- just to make it work in tests
		if( player )then
			self.OrigX = player.X;
			self.OrigZ = player.Z;
		end
		self.Radius = 500;
		self.FileName = nil;
		self.Mode = "waypoints";
		self.KillZone = {};
		self.ExcludeZones = {}
		self.ResumePoint = nil

		self.Type = 0; -- UNSET
		self.ForcedType = 0; 	-- Wp type to overwrite current type, can be used by users in WP coding
	end
);

function CWaypointList:load(filename)

	local root = parser:open(filename);
	local file_ok = true;

	if( not root ) then
		error(sprintf("Failed to load waypoints from \'%s\'", filename), 0);
	end
	if( not language)then
		sprintf("Warning: No language files included");
	end

	local elements = root:getElements();

	local type = root:getAttribute("type");

	if( type ) then
		if( type == "TRAVEL" ) then
			self.Type = WPT_TRAVEL;
		elseif( type == "NORMAL" ) then
			self.Type = WPT_NORMAL;
		elseif( type == "RUN" ) then
			self.Type = WPT_RUN;
		else
			self.Type = WPT_NORMAL;
		end
	else
		self.Type = WPT_NORMAL;
	end

	self.FileName = string.match(filename,"waypoints/(.*)");
	self.Waypoints = {}; -- Delete current waypoints.
	self.ForcedType = 0;	-- delete forced waypoint type

	local onLoadEvent = nil;
	local index = 1;

	for i,v in pairs(elements) do
		--print_r(v);
		local x,z,y = v:getAttribute("x"), v:getAttribute("z"), v:getAttribute("y");
		local type = v:getAttribute("type");
		local action = v:getValue();
		local name = v:getName() or "";
		local tag = v:getAttribute("tag");
		local map = v:getAttribute("map");
		local id = v:getAttribute("id");
		local deviation = v:getAttribute("deviation");
		local inair = v:getAttribute("inair");
		local mounted = v:getAttribute("mounted");
		local comments = v:getAttribute("comments");
		local randomfollow = v:getAttribute("randomfollow");
		local randombefore = v:getAttribute("randombefore");
		local wpstop = v:getAttribute("nostop") or v:getAttribute("WP_NO_STOP");
		local wpzone = v:getAttribute("zone") or  v:getAttribute("WP_ZONE");
		local wpco  = v:getAttribute("nothread") or v:getAttribute("WP_NO_COROUTINE");

		if( string.lower(name) == "waypoint" ) and x and z then
			local tmp = CWaypoint(x, z, y);
			if( action ) then tmp.Action = action; end;
			if( type ) then
				if( type == "TRAVEL" ) then
					tmp.Type = WPT_TRAVEL;
				elseif( type == "RUN" ) then
					tmp.Type = WPT_RUN;
				elseif( type == "NORMAL" ) then
					tmp.Type = WPT_NORMAL;
				else
					-- Undefined type, assume WPT_NORMAL
					tmp.Type = WPT_NORMAL;
				end
			else
				-- No type set, assume Type from header tag
				tmp.Type = self.Type;
			end
			-- some extra which allow to find out if an waypoint is part of the waypoint file list or 'virtual'
			tmp.Virtual = false;

			if( tag ) then tmp.Tag = string.lower(tag); end;
			if( map ) then tmp.Map = map; end;
			if( comments ) then tmp.Comments = comments; end;
			if( inair ) then tmp.InAir = inair; end;
			if( deviation )then tmp.Deviation = deviation; end;
			if( mounted ) then tmp.Mounted = mounted; end;
			if ( id ) then
				tmp.Id = id;
				if(id ~= (index - 1))then
					file_ok = false
				end
			else file_ok = false end;
			if( randomfollow ) then
				local t = {}
				local i = 1;

				for token in string.gmatch(randomfollow, "[^,]+") do

					t[i] = token;
					i= i + 1;
				end

				tmp.RandomFollow = t;
			end
			if( randombefore ) then
				local t = {}
				local i = 1;

				for token in string.gmatch(randombefore, "[^,]+") do

					t[i] = token;
					i= i + 1;
				end

				tmp.RandomBefore = t;
			end
			if ( wpstop ) then tmp.NoStop = wpstop; end;
			if ( wpzone ) then tmp.Zone =   wpzone; end;
			if ( wpco) then tmp.NoThread = wpco; end;

			table.insert(self.Waypoints, tmp);
		elseif( string.lower(name) == "onload" ) then
			if( string.len(action) > 0 and string.find(action, "%w") ) then
				self.onLoadString = action;
				self.onLoadEvent = loadstring(action);


				if( language )then assert(self.onLoadEvent, sprintf(language[152])) else assert(self.onLoadEvent,sprintf("Failed to compile and run Lua code for waypointlist onLoad event.")) end;

				if( _G.type(self.onLoadEvent) ~= "function" ) then
					self.onLoadEvent = nil;
				end;
			end
		end
		index = index + 1;
	end
	if(file_ok == false and waypointlists.settings.rewrite_waypoint)then
		self:save(filename);
	end
	self.Mode = "waypoints"
	if( not player)then
		sprintf("Warning: No player.lua included falling back to first start point from waypoint file");
	end
	if( player )then
		if #self.Waypoints > 0 then
			self:setWaypointIndex(self:getNearestWaypoint(player.X, player.Z, player.Y));
			self.LastWaypoint = self.CurrentWaypoint -1
			if self.LastWaypoint < 1 then self.LastWaypoint = #self.Waypoints end
		end
	end

	if( self.onLoadEvent ) then
		self.DoOnload = true
	end
end

function CWaypointList:add( waypoint )
	table.insert(self.Waypoints, waypoint);
end

function CWaypointList:getFileName()
	if( self.FileName == nil ) then
		return "<NONE>";
	else
		return self.FileName;
	end
end

function CWaypointList:setMode(mode)
	self.Mode = mode;
end

function CWaypointList:setForcedWaypointType(_type)

	if( _type == nil  or  _type == ""  or  _type == 0 ) then
		self.ForcedType = 0;
		cprintf(cli.green, "Forced waypoint type cleared.\n" );
		return;
	end;

	if( _type == "NORMAL"  or  _type == WPT_NORMAL ) then
		self.ForcedType = WPT_NORMAL;
	elseif( _type == "TRAVEL"  or  _type == WPT_TRAVEL) then
		self.ForcedType = WPT_TRAVEL;
	elseif( _type == "RUN"  or  _type == WPT_RUN) then
		self.ForcedType = WPT_RUN;
	else
		cprintf(cli.yellow, "You try to force an unknown waypoint type \'%s\'. Please check.\n", _type);
		error("Bot finished due to error above.", 0);
	end
	player.Current_waypoint_type = self.ForcedType

	cprintf(cli.green, "Forced waypoint type \'%s\' set by user.\n", _type );
end

function CWaypointList:getMode()
	return self.Mode;
end

function CWaypointList:getRadius()
	return self.Radius;
end

function CWaypointList:advance()
	self.LastWaypoint = self.CurrentWaypoint
	if( self.Direction == WPT_FORWARD ) then
		self.CurrentWaypoint = self.CurrentWaypoint + 1;
		if( self.CurrentWaypoint > #self.Waypoints ) then
			self.CurrentWaypoint = 1;
		end
	else
		self.CurrentWaypoint = self.CurrentWaypoint - 1;
		if( self.CurrentWaypoint < 1 ) then
			self.CurrentWaypoint = #self.Waypoints;
		end
	end
end

function CWaypointList:backward()
	self.LastWaypoint = self.CurrentWaypoint
	if( self.Direction == WPT_FORWARD ) then
		self.CurrentWaypoint = self.CurrentWaypoint - 1;
		if( self.CurrentWaypoint < 1 ) then
			self.CurrentWaypoint = #self.Waypoints;
		end
	else
		self.CurrentWaypoint = self.CurrentWaypoint + 1;
		if( self.CurrentWaypoint > #self.Waypoints ) then
			self.CurrentWaypoint = 1;
		end
	end
end

function CWaypointList:getNextWaypoint(_num)
	if( not _num ) then _num = 0; end;
	local tmp;

	local hf_wpnum;
	-- we jump over the waypoint if it is bigger than 1
	if ( self.Waypoints[self.CurrentWaypoint].RandomFollow and self.Direction == WPT_FORWARD)then

		math.randomseed(os.time())

		local answer = math.random(1,#self.Waypoints[self.CurrentWaypoint].RandomFollow);
		local waypoint_id_or_tag = self.Waypoints[self.CurrentWaypoint].RandomFollow[answer];
		local n;


		if(type(waypoint_id_or_tag) == "string")then

			for i,v in pairs(self.Waypoints) do
				if( v.Tag ==  string.lower(waypoint_id_or_tag) ) then
					n = i;
				end
			end

		else

			for i,v in pairs(self.Waypoints) do
				if( v.Id ==  waypoint_id_or_tag) then
					n = i;
				end
			end

		end
		-- we found the random point
		if n then
			hf_wpnum = n;
		end
	end
	-- symmetry a must ...
	if ( self.Waypoints[self.CurrentWaypoint].RandomBefore  and not self.Direction ~= WPT_FORWARD)then

		math.randomseed(os.time())

		local answer = math.random(1,#self.CurrentWaypoint.RandomBefore);
		local waypoint_id_or_tag = self.Waypoints[self.CurrentWaypoint].RandomBefore[answer];
		local n;


		if(type(waypoint_id_or_tag) == "string")then

			for i,v in pairs(self.Waypoints) do
				if( v.Tag ==  string.lower(waypoint_id_or_tag) ) then
					n = i;
				end
			end

		else

			for i,v in pairs(self.Waypoints) do
				if( v.Id ==  waypoint_id_or_tag) then
					n = i;
				end
			end

		end
		-- we found the random point
		if n then
			hf_wpnum = n;
		end
	end

	-- we don't adjust when go random only in case we found nothing we go further
	if not ( self.Waypoints[self.CurrentWaypoint].RandomFollow  or self.Waypoints[self.CurrentWaypoint].RandomBefore) and not hf_wpnum then
		if( self.Direction == WPT_FORWARD ) then
			hf_wpnum = self.CurrentWaypoint + _num;
		else
			hf_wpnum = self.CurrentWaypoint - _num;
		end
	end
	if  (self.Waypoints[self.CurrentWaypoint].RandomFollow  or self.Waypoints[self.CurrentWaypoint].RandomBefore) and _num ~= 1 and hf_wpnum then
		if( self.Direction == WPT_FORWARD ) then
			hf_wpnum = hf_wpnum + _num;
		else
			hf_wpnum = hf_wpnum - _num;
		end
	end

	if( hf_wpnum > #self.Waypoints ) then
		hf_wpnum = hf_wpnum - #self.Waypoints;
	elseif( hf_wpnum < 1 ) then
		hf_wpnum = hf_wpnum + #self.Waypoints;
	end

	local tmp = CWaypoint(self.Waypoints[hf_wpnum]);
	tmp.wpnum = hf_wpnum;

	-- check if forced type is set, that could be done by users
	-- within lua coding in the waypoint tags
	if(self.ForcedType ~= 0 ) then
		tmp.Type = self.ForcedType;
	end

	if( settings.profile.options.WAYPOINT_DEVIATION < 2 and (tmp.Deviation == nil or tmp.Deviation < 2) ) then
		return tmp;
	end

	local halfdev = tmp.Deviation or settings.profile.options.WAYPOINT_DEVIATION;
	local halfdev  = halfdev/2;

	tmp.X = tmp.X + math.random(halfdev) - halfdev;
	tmp.Z = tmp.Z + math.random(halfdev) - halfdev;

	return tmp;
end

-- Sets the "direction" (forward/backward) to travel
function CWaypointList:setDirection(wpt)
	-- Ignore invalid types
	if( wpt ~= WPT_FORWARD and wpt ~= WPT_BACKWARD ) then
		return;
	end;

	if( wpt ~= self.Direction ) then
		self.Direction = wpt
		if( wpt == WPT_BACKWARD ) then
			self.CurrentWaypoint = self.CurrentWaypoint - 2;
			if( self.CurrentWaypoint < 1 ) then
				self.CurrentWaypoint = #self.Waypoints + self.CurrentWaypoint;
			end
		else
			self.CurrentWaypoint = self.CurrentWaypoint + 2;
			if( self.CurrentWaypoint > #self.Waypoints ) then
				self.CurrentWaypoint = self.CurrentWaypoint - #self.Waypoints;
			end
		end;
	end
end

-- Reverse your current direction
function CWaypointList:reverse()
	if( self.Direction == WPT_FORWARD ) then
		self:setDirection(WPT_BACKWARD);
	else
		self:setDirection(WPT_FORWARD);
	end;
end

-- Sets the next waypoint to move to to whatever
-- index you want.
function CWaypointList:setWaypointIndex(index)
	if( type(index) ~= "number" ) then
		error("setWaypointIndex() requires a number. Received " .. type(index), 2);
	end
	if( index < 1 ) then index = 1; end;
	if( index > #self.Waypoints ) then index = #self.Waypoints; end;
	self.LastWaypoint = self.CurrentWaypoint
	self.CurrentWaypoint = index;
end

-- Returns an index to the waypoint closest to the given point.
function CWaypointList:getNearestWaypoint(_x, _z, _y, _start, _end, _plain)

	local do_we_found = false;
	local hight = settings.profile.options.DROPHEIGHT or 35;


	if type(_start) == "string" then
		_start = self:findWaypointTag(_start)
	end
	if type(_end) == "string" then
		_end = self:findWaypointTag(_end)
	end
	---make it adaptable
	if type(_start) == "boolean" then
		_plain = _start;
		_start = nil;
		_end = nil;
	end

	if type(_end) == "boolean" then
		_plain = _end;
		_end = nil;
	end

	if _start and _start < 1 then _start = 1 end
	if _end and _end > #self.Waypoints then _end = #self.Waypoints end

	local closest = _start or 1;

	for i = (_start or 1), (_end or #self.Waypoints) do
		local v = self.Waypoints[i];
		local oldClosestWp = self.Waypoints[closest];

		if( _plain  and v.Y and _y)then
			if( distance(_x, _z, _y, v.X, v.Z, v.Y) < distance(_x, _z, _y, oldClosestWp.X, oldClosestWp.Z, oldClosestWp.Y) and math.abs(_y - v.Y) < hight + 5 ) then
				do_we_found = true;
				closest = i;
			end
		else
			-- this waypoint has no Y value or we don't have Y from player or we ignore it totally
			if( distance(_x, _z, _y, v.X, v.Z, v.Y) < distance(_x, _z, _y, oldClosestWp.X, oldClosestWp.Z, oldClosestWp.Y) ) then
				do_we_found = true;
				closest = i;
			end
		end
	end
	-- if no result try finding some point outside our hight level
	if(do_we_found == false and  _plain)then
		return self:getNearestWaypoint(_x, _z, _y, _start,_end, false)
	end

	return closest;
end

function CWaypointList:findWaypointTag(tag)
	tag = string.lower(tag);
	for i,v in pairs(self.Waypoints) do
		if( v.Tag == tag ) then
			return i;
		end
	end

	return 0;
end

function CWaypointList:setKillZone(_zone)
	-- Reset Kill Zone
	if _zone == nil or _zone == "" or (type(_zone) == "table" and #_zone == 0) then
		self:clearKillZone()
		return
	end

	-- Check argument
	if type(_zone) == "table" then
		-- check table values
		for k,v in pairs(_zone) do
			if (not v.X) or (not v.Z) then
				error("SetKillZone: Invalid table.",0)
			end
		end
	elseif type(_zone) == "string" then
		if not string.find(_zone,".xml", 1, true) then
			_zone = _zone .. ".xml"
		end
		local filename = getExecutionPath() .. "/waypoints/" .. _zone
		if not fileExists(filename) then
			filename = getExecutionPath() .. "/../romglobal/waypoints/" .. _zone
		end
		local file, err = io.open(filename, "r");
		if file then
			file:close();
			local tmpWPL = CWaypointList();
			tmpWPL:load(filename);
			_zone = table.copy(tmpWPL.Waypoints)
		else
			error("SetKillZone: invalid file name.",0)
		end
	else
		error("SetKillZone: Invalid argument.",0)
	end

	-- Set kill zone
	self:clearKillZone()
	for i = 1, #_zone do
		self.KillZone[i] = {X=_zone[i].X, Z=_zone[i].Z}
	end
end

function CWaypointList:clearKillZone()
	self.KillZone = {}
end

function CWaypointList:addExcludeZone(_zone,_zonename)
	-- Check argument
	if type(_zone) == "table" then
		-- check table values
		for k,v in pairs(_zone) do
			if (not v.X) or (not v.Z) then
				error("AddExcludeZone: Invalid table.",0)
			end
		end
	elseif type(_zone) == "string" then
		if not string.find(_zone,".xml", 1, true) then
			_zone = _zone .. ".xml"
		end
		local filename = getExecutionPath() .. "/waypoints/" .. _zone
		if not fileExists(filename) then
			filename = getExecutionPath() .. "/../romglobal/waypoints/" .. _zone
		end
		local file, err = io.open(filename, "r");
		if file then
			file:close();
			local tmpWPL = CWaypointList();
			tmpWPL:load(filename);
			_zone = table.copy(tmpWPL.Waypoints)
		else
			error("AddExcludeZone: invalid file name.",0)
		end
	else
		error("AddExcludeZone: Invalid argument.",0)
	end

	local tmp = {}
	for i = 1, #_zone do
		tmp[i] = {X=_zone[i].X, Z=_zone[i].Z}
	end

	-- Add Exclude Zone
	if _zonename then
		self.ExcludeZones[_zonename] = table.copy(tmp)
	else
		table.insert(self.ExcludeZones,tmp)
	end
end

function CWaypointList:deleteExcludeZone(_zonename)
	for name,zone in pairs(self.ExcludeZones) do
		if name == _zonename then
			self.ExcludeZones[name] = nil
			return
		end
	end
end

function CWaypointList:clearExcludeZones()
	self.ExcludeZones = {}
end



function CWaypointList:updateResume()
	if self.Mode ~= "wander" then
		local file=io.open(getExecutionPath() .. "/logs/resumes/"..player.Name..".txt","w")
		if file then
			file:write("return \""..self.FileName.."\", "..self.CurrentWaypoint)
			file:close()
		end
	end
end
-- After a pullback, use this function to find the waypoint you were pulled before.
function CWaypointList:findPulledBeforeWaypoint(_start, _end, _near, _look)
	local WPCount = #self.Waypoints

	-- If 1 or 2 then it can't change.
	if WPCount < 3 then
		return self.CurentWaypoint
	end

	--local DistLimit =  1000 -- Limits distance to look back from current waypoint.
	local wpende =  _end or 0
	local wptotest = _start or self.CurrentWaypoint
	local bestwaypointindex = self.CurrentWaypoint -- Best waypoint index so far
	local bestdist -- Best distance to path so far
	local near_enough = _near or 30;
	local look_further = _look or -2;
	local found = false;
	if( self.Direction == WPT_FORWARD ) then
		repeat
			local towp = self.Waypoints[wptotest]
			local fromwp = self.Waypoints[wptotest-1]
			if fromwp == nil then fromwp = self.Waypoints[#self.Waypoints] end

			-- First find segment point
			local segpoint = getNearestSegmentPoint(player.X, player.Z, player.Y, towp.X, towp.Z, towp.Y, fromwp.X, fromwp.Z, fromwp.Y)

			-- if segpoint = towp or fromwp then it isn't between the wps
			if not (segpoint.X == towp.X and segpoint.Z == towp.Z) and not (segpoint.X == fromwp.X and segpoint.Z == fromwp.Z) then
				-- Get player distance to segment
				local tmpdist = distance(player, segpoint)
				-- See if it's a better match
				if bestdist == nil or tmpdist < bestdist then -- Compare
					bestdist = tmpdist
					bestwaypointindex = wptotest
				end
				--we check the next 2 also but we found out canidate we cut the rest to avoid crossings
				if tmpdist <= near_enough and not found then
					wpende = wptotest - look_further;
					found = true;
				end
			end

			-- Check how far we are from currentwaypoint
			if wpende <= wptotest then -- Exceeded limit. Return best score
				return bestwaypointindex
			end

			wptotest = wptotest - 1

			if wptotest < 1 then wptotest = #self.Waypoints end
		until wptotest == self.CurrentWaypoint -- Gone through all points
	else
		repeat
			local towp = self.Waypoints[wptotest]
			local fromwp = self.Waypoints[wptotest+1]
			if fromwp == nil then fromwp = self.Waypoints[1] end

			-- First find segment point
			local segpoint = getNearestSegmentPoint(player.X, player.Z, player.Y, towp.X, towp.Z, towp.Y, fromwp.X, fromwp.Z, fromwp.Y)

			-- if segpoint = towp or fromwp then it isn't between the wps
			if not (segpoint.X == towp.X and segpoint.Z == towp.Z) and not (segpoint.X == fromwp.X and segpoint.Z == fromwp.Z) then
				-- Get player distance to segment
				local tmpdist = distance(player, segpoint)
				-- See if it's a better match
				if bestdist == nil or tmpdist < bestdist then -- Compare
					bestdist = tmpdist
					bestwaypointindex = wptotest
				end
				--we check the next 2 also but we found out canidate we cut the rest to avoid crossings
				if tmpdist <= near_enough and not found then
					wpende = wptotest - look_further;
					found = true;
				end
			end

			-- Check how far we are from currentwaypoint
			if wpende <= wptotest then -- Exceeded limit. Return best score
				return bestwaypointindex
			end

			wptotest = wptotest + 1


		until wptotest == #self.CurrentWaypoint -- Gone through all points
	end

	return bestwaypointindex
end
function CWaypointList:insert(waypoint, position)

	-- we added it to the end
	if(position == nil)then
		position = #self.Waypoints + 1;
	end

	-- must be tested
	for  i = position - 1, 2, -1 do
		self.Waypoints[i+1] = self.Waypoints[i];
	end
	self.Waypoints[position] = waypoint;
end
function CWaypointList:save(filename)

	--xml.save(list,"test.xml");
	local file, err = io.open(filename, "w");
	--basic strings
	local openformat1 = "\t<!-- #%3d --><waypoint id=\"%d\" x=\"%d\" z=\"%d\" y=\"%d\"%s>%s";
	-- we have no y
	local openformat2 = "\t<!-- #%3d --><waypoint id=\"%d\" x=\"%d\" z=\"%d\" %s>%s";
	local closeformat = "</waypoint>\n";

	--- get info about the waypoints in general
	--local type = root:getAttribute("type");
	--local elements = root:getElements();

	local typebase ;
	if(self.Type == WPT_NORMAL)then
		typebase = nil;
	end
	if(self.Type == WPT_TRAVEL)then
		typebase = "TRAVEL";
	end
	if(self.Type == WPT_RUN)then
		typebase = "RUN";
	end

	file:write("<?xml version=\"1.0\" encoding=\"utf-8\"?>");

	local str;

	if (typebase)then
		str = sprintf("<waypoints %s>\n"," type=\""..typebase.."\"");	-- create first tag
	else
		str = sprintf("<waypoints>\n");
	end

	local onload_s = self.onLoadString;


	if(  onload_s )then
		str =str.. "\n <onLoad>  "..onload_s.." </onLoad> \n";
	end
	file:write(str);					-- write first tag

	local hf_line, tag_open = "", false;
	local help_line= "";
	local line_num = 1;
	local running = false;
	local type_changed = false;
	for i,v in pairs(self.Waypoints) do
		local type = nil;
		if(not self.Type)then
			type_changed = true
		end
		if (self.Type and v.Type and v.Type ~= self.Type)then
			type_changed = true
		else
			type_changed = false
		end

		if(v.Type and v.Type == WPT_NORMAL)then
			if(type_changed == true)then
				type = "NORMAL";
			end
		end
		if(v.Type and v.Type == WPT_TRAVEL)then
			if(type_changed == true)then
				type = "TRAVEL";
			end
		end
		if(v.Type and v.Type == WPT_RUN)then
			if(type_changed == true)then
				type = "RUN";
			end
		end
		if(v.Map ~= nil )then
			help_line = help_line.." map=\""..v.Map.."\" ";
		end
		if(v.Tag ~= nil and v.Tag ~= "")then
			help_line = help_line.." tag=\""..v.Tag.."\" ";
		end
		if(v.Zone ~= nil)then
			help_line = help_line.." zone=\""..v.Zone.."\" ";
		end
		if(v.Deviation ~= nil)then
			help_line = help_line.." deviation=\""..v.Deviation.."\" ";
		end
		if(v.Comments ~= nil)then
			help_line = help_line.." zone=\""..v.Comments.."\" ";
		end
		if(v.Mounted ~= nil)then
			if(v.Mounted)then
				help_line = help_line.." mounted=\"true\" ";
			else
				help_line = help_line.." mounted=\"false\" ";
			end
		end
		if(v.InAir ~= nil)then
			if(v.InAir)then
				help_line = help_line.." inair=\"true\" ";
			else
				help_line = help_line.." inair=\"false\" ";
			end
		end
		if(v.NoThread ~= nil)then
			if(v.NoThread)then
				help_line = help_line.." nothread=\"true\" ";
			else
				help_line = help_line.." nothread=\"false\" ";
			end
		end

		if(v.NoStop ~=nil)then
			if(v.NoStop)then
				help_line = help_line.." nostop=\"true\" ";
				running = true;
			else
				help_line = help_line.." nostop=\"false\" ";
				running = false;
			end

		end
		if(v.Action)then
			if(v.Action:match( "^%s*(.-)%s*$" ) == nil or v.Action:match( "^%s*(.-)%s*$" ) == "")then
				if(not running and v.NoStop == nil)then
					help_line = help_line.." nostop=\"true\" ";
					running = true;
					v.NoStop = true;
				end
			else
				if(running and v.NoStop == nil)then
					help_line = help_line.." nostop=\"false\" ";
					running = false;
					v.NoStop = false;
				end
			end
		end
		if(v.RandomFollow ~= nil)then
			help_line = help_line.." randomfollow=\"";
			for index,value in pairs(v.RandomFollow) do
				help_line = help_line..","..value;
			end
			help_line = help_line.."\" ";
		end
		if(v.RandomBefore ~= nil)then
			help_line = help_line.." randombefore=\"";
			for index,value in pairs(v-RandomBefore) do
				help_line = help_line..","..value;
			end
			help_line = help_line.."\" ";
		end


		if( tag_open ) then
			if ( hf_data ) then
				hf_line = hf_line .. "\n" .. closeformat
			else
				hf_line = hf_line .. closeformat
			end
		end

		if(v.Type and type)then

			if(v.Action)then
				if( v.Y )then
					hf_line = hf_line .. sprintf(openformat1, line_num, line_num, v.X, v.Z, v.Y, help_line.." type=\""..type.."\"", ""..v.Action.."");
				else
					hf_line = hf_line .. sprintf(openformat2, line_num, line_num, v.X, v.Z, help_line.." type=\""..type.."\"", ""..v.Action.."");
				end
			else
				if( v.Y )then
					hf_line = hf_line .. sprintf(openformat1, line_num,line_num, v.X, v.Z, v.Y, help_line.." type=\""..type.."\"", "")
				else
					hf_line = hf_line .. sprintf(openformat2, line_num,line_num, v.X, v.Z, help_line.." type=\""..type.."\"", "")
				end
			end
		else
			if(v.Action)then
				if( v.Y )then
					hf_line = hf_line .. sprintf(openformat1, line_num,line_num, v.X, v.Z, v.Y, help_line, ""..v.Action.."")
				else
					hf_line = hf_line .. sprintf(openformat2, line_num,line_num, v.X, v.Z, help_line, ""..v.Action.."")
				end
			else
				if( v.Y )then
					hf_line = hf_line .. sprintf(openformat1, line_num, line_num, v.X, v.Z, v.Y, help_line,"")
				else
					hf_line = hf_line .. sprintf(openformat2, line_num, line_num, v.X, v.Z, help_line,"")
				end
			end
		end

		line_num = line_num + 1
		tag_open = true;
		hf_data = false;
		help_line ="";
	--hf_line = hf_line .. sprintf(openformat, i,i, v.X, v.Z, v.Y,commands)
	--"\n\t\t" .. sprintf(p_merchant_command, v.npc_name) ) .. "\n";
	--	tag_open = true;

	end

	-- If we left a tag open, close it.
	if( tag_open ) then
		hf_line = hf_line .. "\t" .. closeformat;
	end

	if(bot and  bot.ClientLanguage == "RU" ) then
		hf_line = oem2utf8_russian(hf_line);		-- language conversations for Russian Client
	end

	file:write(hf_line);
	file:write("</waypoints>");


end



