-- get current directory (theres gotho be an easier way)
function currDir()
  os.execute("cd > cd.tmp")
  local f = io.open("cd.tmp", r)
  local cwd = f:read("*a")
  f:close()
  os.remove("cd.tmp")
  return cwd
end

function getWin(character)
	if( __WIN == nil ) then
  		__WIN = selectGame(character);
	end

	return __WIN;
end

function getProc()
	if( __PROC == nil or not windowValid(__WIN) ) then
		if( __PROC ) then closeProcess(__PROC) end;
		__PROC = openProcess( findProcessByWindow(getWin()) );
	end

	return __PROC;
end

function angleDifference(angle1, angle2)
  if( math.abs(angle2 - angle1) > math.pi ) then
    return (math.pi * 2) - math.abs(angle2 - angle1);
  else
    return math.abs(angle2 - angle1);
  end
end

function distance(x1, z1, y1, x2, z2, y2)
	if type(x1) == "table" and type(z1) == "table" then
        y2 = z1.Y or z1[3]
        z2 = z1.Z or z1[2]
        x2 = z1.X or z1[1]
        y1 = x1.Y or x1[3]
        z1 = x1.Z or x1[2]
        x1 = x1.X or x1[1]
    elseif z2 == nil and y2 == nil then -- assume x1,z1,x2,z2 values (2 dimensional)
		z2 = x2
		x2 = y1
		y1 = nil
	end

	if( x1 == nil or z1 == nil or x2 == nil or z2 == nil ) then
		error("Error: nil value passed to distance()", 2);
	end

	if y1 == nil or y2 == nil then -- 2 dimensional calculation
		return math.sqrt( (z2-z1)*(z2-z1) + (x2-x1)*(x2-x1) );
	else -- 3 dimensional calculation
		return math.sqrt( (z2-z1)*(z2-z1) + (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) );
	end
end

-- returns full path if it exists, searching relative, local and global folders
-- To be found, _file path should be relative to 'rom' or 'romglobal' or the current waypoint file.
function findFile(_file)
	-- Check relative to current wp files location.
	if __WPL and __WPL.FileName then
		-- we strip "waypoints/" since we search relative to current waypoint location.
		local tmpFile = string.gsub(_file,"^/?waypoints/","")

		local currentWPLPath = string.match(__WPL.FileName,"(.+/)") or ""

		-- Simple nested folder
		if fileExists(getExecutionPath() .. "/waypoints/" .. currentWPLPath .. tmpFile) then
			return getExecutionPath() .. "/waypoints/" .. currentWPLPath .. tmpFile
		end

		-- Strip duplicate dirs
		local tmpPath = string.match(tmpFile, "^(.*%/).*%....")
		if tmpPath then
			repeat
				if string.match(currentWPLPath, tmpPath .. "$") then
					-- Match found, strip dirs
					currentWPLPath = string.match(currentWPLPath, "(.*)"..tmpPath.."$")
					if fileExists(getExecutionPath() .. "/waypoints/" .. currentWPLPath .. tmpFile) then
						return getExecutionPath() .. "/waypoints/" .. currentWPLPath .. tmpFile
					end
				end
				-- Take off a dir and try again
				tmpPath = string.match(tmpPath, "^(.-)[^%/]*%/$")
			until tmpPath == ""
		end
	end

	-- Then check local folder
	if fileExists(getExecutionPath() .. "/" .. _file) then
		return getExecutionPath() .. "/" .. _file
	end

	-- Then check global folder
	if fileExists(getExecutionPath() .. "/../romglobal/" .. _file) then
		return getExecutionPath() .. "/../romglobal/" .. _file
	end

	-- if neither exist return local as default
	return getExecutionPath() .. "/" .. _file
end

function load_paths( _wp_path, _rp_path)

	cprintf(cli.yellow, "Please use the renamed function \'loadPaths()\' instead of \'load_paths\'!\n");
	loadPaths( _wp_path, _rp_path);

end

function loadPaths( _wp_path, _rp_path)
-- load given waypoint path and return path file
-- if you don't specify a return path the function will look for
-- a default return path based on the waypoint path name and
-- the settings.profile.options.RETURNPATH_SUFFIX


	-- check if function is not called empty
	if( _wp_path == "" or _wp_path == " " ) then _wp_path = nil; end;
	if( _rp_path == "" or _rp_path == " " ) then _rp_path = nil; end;
	if( not _wp_path ) and ( not _rp_path ) then
		cprintf(cli.yellow, language[161]);	 -- have to specify either
		return;
	end;

	-- check suffix and remember default return path name
	local rp_default;
	if(_wp_path ~= nil) then
		local foundpos = string.find(_wp_path,".xml",1,true);	-- filetype defined?
		if( foundpos ) then					-- filetype defined
			rp_default = string.sub(_wp_path,1,foundpos-1) .. settings.profile.options.RETURNPATH_SUFFIX .. ".xml";
		else							-- no filetype
			rp_default = _wp_path .. settings.profile.options.RETURNPATH_SUFFIX .. ".xml";
		end;
	end;

	if( _wp_path and not string.find(_wp_path,".xml", 1, true) and _wp_path ~= "wander" and _wp_path ~= "resume" ) then
		_wp_path = _wp_path .. ".xml";
	end;
	if( _rp_path  and   not string.find(_rp_path,".xml", 1, true) ) then
		_rp_path = _rp_path .. ".xml";
	end;

	-- waypoint path is defined

	-- check if _wp_path exists
	local wpfilename
	if( _wp_path and
		string.lower(_wp_path) ~= "wander" and
		string.lower(_wp_path) ~= "resume" ) then
		local filename
		if _wp_path:sub(2,2) == ":" then
			filename = _wp_path
		else
			filename = findFile("waypoints/" .. _wp_path )
		end
		if not fileExists(filename) then
			local msg = sprintf(language[142], filename ); -- We can't find your waypoint file
			error(msg, 2);
		end
		__WPL = CWaypointList();
		wpfilename = filename
		cprintf(cli.yellow, language[0], _wp_path);	-- Loaded waypoint path
	end

	-- set wander for WP
	if( string.lower(_wp_path) == "wander" ) then
		__WPL = CWaypointListWander();
		__WPL:setRadius(settings.profile.options.WANDER_RADIUS);
		__WPL:setMode("wander");
		cprintf(cli.green, language[168], settings.profile.options.WANDER_RADIUS);	-- Loaded waypoint path
	end

	if( string.lower(_wp_path) == "resume" ) then
		local resumelogname = getExecutionPath() .. "/logs/resumes/"..player.Name..".txt"
		if not fileExists(resumelogname) then
			local msg = sprintf(language[142], resumelogname ); -- We can't find your waypoint file
			error(msg, 2);
		end
		local filename, resume_num = dofile(resumelogname)

		wpfilename = findFile("waypoints/"..filename)
		__WPL = CWaypointList();
		__WPL.ResumePoint = resume_num
		cprintf(cli.yellow, language[0], wpfilename);	-- Loaded waypoint path
	end

	-- look for default return path with suffix '_return'
	if( not _rp_path ) then
		local filename = findFile("waypoints/" .. rp_default)
		if fileExists(filename) then
			cprintf(cli.green, language[162], rp_default );	-- Return path found with default naming
			_rp_path = rp_default;	-- set default
		else
			cprintf(cli.lightgray, language[163], rp_default );	-- No return path with default naming
		end;
	end

	-- check if _rp_path exists
	local rpfilename
	if( _rp_path ) then
		if( not __RPL ) then  		-- define object if not there
			__RPL = CWaypointList();
		end;
		local filename = findFile("waypoints/" .. _rp_path)
		if not fileExists(filename) then
			local msg = sprintf(language[143], _rp_path ); -- We can't find your returnpath file
			error(msg, 0);
		end;
		rpfilename = filename
		cprintf(cli.green, language[1], _rp_path);	-- Loaded return path
	end

	-- check if on returnpath
	if( player.Returning == true  and
	    _rp_path ) then
		cprintf(cli.green, language[164], _rp_path);	-- We are coming from a return_path.
	else
		player.Returning = false;
		cprintf(cli.green, language[165], _wp_path );-- We use the normal waypoint path %s now
	end

	-- waypoint path is defined ... load it
	if wpfilename then
		__WPL:load(wpfilename);
		if __WPL.ResumePoint and __WPL.Waypoints[__WPL.ResumePoint] then
			__WPL.CurrentWaypoint = __WPL.ResumePoint
		elseif(__WPL.CurrentWaypoint ~= 1 ) then --and #__WPL.Waypoints > 0
			cprintf(cli.green, language[15], 					-- Waypoint #%d is closer then #1
			   __WPL.CurrentWaypoint, __WPL.CurrentWaypoint);
		end;
	end

	-- return path defined or default found ... load it
	if rpfilename then
		__RPL:load(rpfilename);
	else
		if( __RPL ) then  		-- clear old returnpath object
			__RPL = nil;
		end;
	end;
end

-- UTF8 -> DOS(OEM) Code page 866 conversation for the russian client
-- we use it for the player names & mob names conversion in pawn.lua
-- http://en.wikipedia.org/wiki/Code_page_866
function utf82oem_russian(txt)
  txt = string.gsub(txt, string.char(0xD0, 0x81), string.char(0xF0) );	-- 0xF0 / E with dots
  txt = string.gsub(txt, string.char(0xD1, 0x91), string.char(0xF1) );	-- 0xF1 / e with dots
  -- lower case
  local patt = string.char(0xD1) .. "([" .. string.char(0x80, 0x2D, 0x8F) .. "])";
  txt = string.gsub(txt, patt, function (s)
            return string.char(string.byte(s,1,1)+0x60);
          end
  );
  -- upper case
  patt = string.char(0xD0) .. "([" .. string.char(0x90, 0x2D, 0xBF) .. "])";
  txt = string.gsub(txt, patt, function (s)
            return string.char(string.byte(s,1,1)-0x10);
          end
  );
  return txt;
end

-- DOS(OEM) -> UTF8 conversation for the russian client
-- we use it within addMessage in functions.lua
function oem2utf8_russian(txt)
  local function translate(code)
         -- upper case and lower case part 1
          if(code>=0x80)and(code<=0xAF)then
              return string.char(0xD0, code+0x10);
          end
         -- lower case part 2
          if(code>=0xE0)and(code<=0xEF)then
              return string.char(0xD1, code-0x60);
          end
          if(code==0xF0)then
              return string.char(0xD0, 0x81); -- E with dots
          end
          if(code==0xF1)then
              return string.char(0xD1, 0x91); -- e with dots
          end
         return string.char(code);
  end

  local result = '';
  for i=1,string.len(txt) do
      result = result .. translate( string.byte(txt,i) );
  end
  return result;
end


-- convert the ingame UTF8 strings to ASCII
-- we use the complete utf8 table, that means for all languages we have
function convert_utf8_ascii( _str )

	-- local function to convert string (e.g. mob name / player name) from UTF-8 to ASCII
	local function convert_utf8_ascii_character( _str, _v )
		local found;
		_str, found = string.gsub(_str, string.char(_v.utf8_1, _v.utf8_2), string.char(_v.ascii) );
		return _str, found;
	end

	local found, found_all;
	found_all = 0;
	for i,v in pairs(database.utf8_ascii) do
--			_str, found = convert_utf8_ascii_character( _str, v.ascii  );	-- replace special characters
		_str, found = convert_utf8_ascii_character( _str, v  );	-- replace special characters
		found_all = found_all + found;									-- count replacements
	end

	if( found_all > 0) then
		return _str, true;
	else
		return _str, false;
	end
end


-- we only replace umlaute, hence only that are important for mob names
-- player names are at the moment not importent for the MM protocol
-- player names will be handled while loading the profile
function utf8ToAscii_umlauts(_str)

	-- convert one UTF8 character to his ASCII code
	-- key is the combined UTF8 code
	local function replaceUtf8( _str, _key )
		local tmp = database.utf8_ascii[_key];
		_str = string.gsub(_str, string.char(tmp.utf8_1, tmp.utf8_2), string.char(tmp.ascii) );
		return _str
	end

	_str = replaceUtf8(_str, 195164);		-- d
	_str = replaceUtf8(_str, 195132);		-- ?
	_str = replaceUtf8(_str, 195182);		-- f
	_str = replaceUtf8(_str, 195150);		-- F
	_str = replaceUtf8(_str, 195188);		-- ?
	_str = replaceUtf8(_str, 195156);		-- ?
	_str = replaceUtf8(_str, 195159);		-- ?
	return _str;
end


-- we only replace umlaute, hence only that are important for
-- printing ingame messages
function asciiToUtf8_umlauts(_str)

	-- convert one ASCII code to his UTF8 character
	-- key is the combined UTF8 code
	local function replaceAscii( _str, _key )
		local tmp = database.utf8_ascii[_key];
		_str = string.gsub(_str, string.char(tmp.ascii), string.char(tmp.utf8_1, tmp.utf8_2) );
		return _str
	end

	_str = replaceAscii(_str, 195164);		-- d
	_str = replaceAscii(_str, 195132);		-- ?
	_str = replaceAscii(_str, 195182);		-- f
	_str = replaceAscii(_str, 195150);		-- F
	_str = replaceAscii(_str, 195188);		-- ?
	_str = replaceAscii(_str, 195156);		-- ?
	_str = replaceAscii(_str, 195159);		-- ?
	return _str;
end

-- change profile options and print values in MM protocol
function changeProfileOption(_option, _value)

	if( settings.profile.options[_option] == nil ) then
		cprintf(cli.green, language[173], _option );	-- Unknown profile option
		return;
	end

	local hf_old_value = settings.profile.options[_option];
	settings.profile.options[_option] = _value;

	cprintf(cli.lightblue, language[172], _option, hf_old_value, _value );	-- We change the option

end

-- change profile skill value and print values in MM protocol
function changeProfileSkill(_skill, _option, _value)

	local skill = nil
	for k,v in pairs(settings.profile.skills) do
		if v.Name == _skill then
			skill = v
			break
		end
	end

	if skill == nil then
		cprintf(cli.green, language[184], _skill );	-- Unknown profile skill
		return;
	end

	local hf_old_value = skill[_option]
	if hf_old_value == nil then hf_old_value = "nil" end
	skill[_option] = _value;

	cprintf(cli.lightblue, language[185], _option, _skill, hf_old_value, _value );	-- We change the option

	-- Resort skills if priority is changed
	if _option == "priority" then
		table.sort(settings.profile.skills, function(a,b) return a.priority > b.priority end)
	end
end

function convertProfileName(_profilename)
	--local usingPlayerName = false
	--if _profilename == player.Name then
	--	usingPlayerName = true
	--end

	local function check_for_userdefault_profile()
		if _profilename == player.Name then
			return ( fileExists(getExecutionPath() .. "/profiles/userdefault.xml") )
		else
			return false
		end
	end

	-- local functions to replace special ASCII characters (e.g. in player name)
	local function replace_special_ascii_character( _str, _v )
		local found;
--		local tmp = database.utf8_ascii[_ascii];
		_str, found = string.gsub(_str, string.char(_v.ascii), _v.dos_replace );
		return _str, found;
	end

	local function replace_special_ascii( _str )
		local found, found_all;
		found_all = 0;
		for i,v in pairs(database.utf8_ascii) do
			_str, found = replace_special_ascii_character( _str, v );	-- replace special characters
			found_all = found_all + found;			-- count replacements
		end

		if( found_all > 0) then
			return _str, true;
		else
			return _str, false;
		end
	end

	local load_profile_name, new_profile_name;	-- name of profile to load

	-- convert player/profile name from UTF-8 to ASCII
	load_profile_name = convert_utf8_ascii(_profilename);

	-- replace special ASCII characters like f?d? / hence open.XML() can't handle them
	new_profile_name , hf_convert = replace_special_ascii(load_profile_name);	-- replace characters

	if( hf_convert ) then		-- we replace some special characters

		-- check if profile with replaced characters allready there
		if( fileExists(getExecutionPath() .. "/profiles/" .. new_profile_name..".xml") ) then
			load_profile_name = new_profile_name;
		else
			-- check if userdefault profile exists
			if check_for_userdefault_profile() then
				load_profile_name = "userdefault"
			else
				local msg = sprintf(language[101], -- we can't use the character/profile name \'%s\' as a profile name
						load_profile_name, new_profile_name);
				error(msg, 0);
			end
		end;
	else
		-- check if profile exist
		if( not fileExists(getExecutionPath() .. "/profiles/" .. load_profile_name..".xml" ) ) then
			-- check if userdefault profile exists
			if check_for_userdefault_profile() then
				load_profile_name = "userdefault"
			else
				local msg = sprintf(language[102], load_profile_name ); -- We can't find your profile
				error(msg, 0);
			end
		end
	end;

	return load_profile_name;
end

local lastDisplayBlocks = nil;
function displayProgressBar(percent, size)
	size = size or 10;
	local blocksFilled = math.floor(size*percent/100);
	local blocksUnfilled = size - blocksFilled;

	if( blocksFilled ~= lastDisplayBlocks ) then
		printf("\r%03d%% [", percent);
		cprintf(cli.turquoise, string.rep("*", blocksFilled));
		printf(string.rep("-", blocksUnfilled) .. "]");

		lastDisplayBlocks = blocksFilled;
		if blocksFilled == size then printf("\n") end
	end
end

function trim(_s)
	return (string.gsub(_s, "^%s*(.-)%s*$", "%1"))
end

function debugMsg(_debug, _reason, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6 )

	-- return if debugging / detail  is disabled
	if( _debug ~= true ) then return; end

	local function make_printable(_v)
		if(_v == true) then
			_v = "<true>";
		elseif(_v == false) then
			_v = "<false>";
		elseif( type(_v) == "table" ) then
			_v = "<table>";
		elseif( type(_v) == "string" ) then
			_v = convert_utf8_ascii(_v)
		end
--		if( type(_v) == "number" ) then
--			_v = sprintf("%d", _v);
--		end
		return _v
	end

	local hf_arg1, hf_arg2, hf_arg3, hf_arg4, hf_arg5, hf_arg6 = "", "", "", "", "", "";
	if(_arg1) then hf_arg1 = make_printable(_arg1); end;
	if(_arg2) then hf_arg2 = make_printable(_arg2); end;
	if(_arg3) then hf_arg3 = make_printable(_arg3); end;
	if(_arg4) then hf_arg4 = make_printable(_arg4); end;
	if(_arg5) then hf_arg5 = make_printable(_arg5); end;
	if(_arg6) then hf_arg6 = make_printable(_arg6); end;


	local msg = sprintf("[DEBUG] %s %s %s %s %s %s %s\n", _reason, hf_arg1, hf_arg2, hf_arg3, hf_arg4, hf_arg5, hf_arg6 ) ;
	msg = string.gsub(msg, "%%", "%%%%");
	cprintf(cli.yellow, msg);

end

-- Returns the point that is nearest to (X,Z,Y) between segment (A,B,C) and (D,E,F)
function getNearestSegmentPoint(x, z, y, a, b, c, d ,e ,f)
	
	local function _2d(x, z, a, b, c, d)
       if a == c and b == d then
			return CWaypoint(a, b)
		end
		local dx1 = x - a;
		local dz1 = z - b;
		local dx2 = c - a;
		local dz2 = d - b;

		local dot = dx1 * dx2 + dz1 * dz2;
		local len_sq = dx2 * dx2 + dz2 * dz2;
		local param = dot / len_sq;

		local nx, nz;

		if( param < 0 ) then
			nx = a;
			nz = b;
		elseif( param > 1 ) then
			nx = c;
			nz = d;
		else
			nx = a + param * dx2;
			nz = b + param * dz2;
		end

		return CWaypoint(nx, nz);
    end
	
	local function _3d(x, z, y, a, b, c, d, e, f)
		if a == d and b == e and c == f then
			return CWaypoint(a, b, c)
		end
		local dx1 = x - a;
		local dz1 = z - b;
		local dy1 = y - c;
	
		local dx2 = d - a;
		local dz2 = e - b;
		local dy2 = f - c;

		local dot = dx1 * dx2 + dz1 * dz2 + dy1 * dy2;
		local len_sq = dx2 * dx2 + dz2 * dz2 + dy2 * dy2;
		local param = dot / len_sq;

		local nx, nz , ny;

		if( param < 0 ) then
			nx = a;
			nz = b;
			ny = c;
		elseif( param > 1 ) then
			nx = d;
			nz = e;
			ny = f;
		else
			nx = a + param * dx2;
			nz = b + param * dz2;
			ny = c + param * dy2;
		end

		return CWaypoint(nx, nz ,ny);
	end
	
	-- last 3 are missing assuming intended 2D calculation
	if e == nil and d == nil and f == nil then
        return _2d(x, z, y, a, b, c)
	-- one or more of every 3th argument missing(height), fall back to 2D
    elseif y == nil or c == nil or f == nil then
        return _2d(x, z, a, b, d, e)
    else
        return _3d(x, z, y, a, b, c, d, e, f)
    end
	
end
function getNearestSegmentPoint3D(x, z, y, a, b, c, d ,e ,f)
	return getNearestSegmentPoint(x, z, y, a, b, c, d ,e ,f);
end
function waitForLoadingScreen(_maxWaitTime)
	local oldAddress = player.Address

	local startTime = os.time()
	-- wait for player address to change
	repeat
		if isClientCrashed() then
			if onClientCrash then
				onClientCrash()
			else
				error("Client crash detected in waitForLoadingScreen().")
			end
		end

		if (_maxWaitTime ~= nil and os.difftime(os.time(),startTime) > _maxWaitTime ) then
			-- Loading screen didn't appear, we return false so waypoint file can try and take alternate action to recover
			cprintf(cli.yellow,"The loading screen didn't appear...\n")
			return false
		end
		rest(1000)
		local newAddress = memoryReadRepeat("uintptr", getProc(), addresses.staticbase_char, addresses.charPtr_offset)
	until (newAddress ~= oldAddress and newAddress ~= 0) or memoryReadBytePtr(getProc(),addresses.loadingScreenPtr, addresses.loadingScreen_offset) ~= 0
	-- wait until loading screen is gone
	repeat
		rest(1000)
	until memoryReadBytePtr(getProc(),addresses.loadingScreenPtr, addresses.loadingScreen_offset) == 0

	rest(2000)
	player:update()
	return true
end

function isInGame()
	-- Note: if not in game, addresses.isInGame + 0xBF4 is 1 when at the character selection screen.
	if memoryReadBytePtr(getProc(),addresses.loadingScreenPtr, addresses.loadingScreen_offset) == 0 and
	   memoryReadInt(getProc(), addresses.isInGame) == 1 then
		return true
	else
		return false
	end
end

-- Parse from |Hitem:33BF1|h|cff0000ff[eeppine ase]|r|h
-- hmm, i whonder if we could get more information out of it than id, color and name.
function parseItemLink(itemLink)
	if itemLink == "" or itemLink == nil then
		return;
 	end

	local s,e, id, color, name = string.find(itemLink, "|Hitem:(%x+).*|h|c(%x+)%[(.+)%]|r|h");
	id = id or "000000"; color = color or "000000";
	id    = tonumber(tostring(id), 16) or 0;
	color = tonumber(tostring(color), 16) or 0;
	name = name or "<invalid>";

	return id, color, name;
end


function GetPartyMemberName(_number)

	if type(_number) ~= "number" or _number < 1 then
		print("GetPartyMemberName(number): incorrect value for 'number'.")
		return
	end

	local listAddress = memoryReadRepeat("uintptr", getProc(), addresses.partyMemberList_address, addresses.partyMemberList_offset )
	local memberAddress = listAddress + (_number - 1) * 0x60

	-- Check if that number exists
	if memoryReadRepeat("byte", getProc(), memberAddress) ~= 1 then
		return nil
	end
	if memoryReadRepeat("byte", getProc(), memberAddress + 0x1C) == 31 then
		memberAddress = memoryReadRepeat("uint", getProc(), memberAddress + 8 )
		local name = memoryReadString(getProc(), memberAddress)
			if( bot.ClientLanguage == "RU" ) then
				name = utf82oem_russian(name);
			else
				name = utf8ToAscii_umlauts(name);   -- only convert umlauts
			end
		return name
	else
		local name = memoryReadString(getProc(), memberAddress + 8)
			if( bot.ClientLanguage == "RU" ) then
				name = utf82oem_russian(name);
			else
				name = utf8ToAscii_umlauts(name);   -- only convert umlauts
			end
		return name
	end
end

function GetPartyMemberAddress(_number)
	local name = GetPartyMemberName(_number)
	if name then
		return player:findNearestNameOrId(name)
	end
end
function Attack()
	if settings.profile.hotkeys.AttackType == nil then
		setupAttackKey()
	end

	local tmpTargetPtr = memoryReadRepeat("uint", getProc(), player.Address + addresses.pawnTargetPtr_offset) or 0

	if tmpTargetPtr == 0 and player.TargetPtr == 0 then
		-- Nothing to attack
		return
	end

	if tmpTargetPtr ~= 0 then
		player.TargetPtr = tmpTargetPtr
		if settings.profile.hotkeys.AttackType == "macro" then
			RoMCode("UseSkill(1,1)")
		else
			keyboardPress(settings.profile.hotkeys.AttackType)
		end
		return
	end

	if player.TargetPtr ~= 0 then
		-- update TargetPtr
		player:updateTargetPtr()
		if player.TargetPtr ~= 0 then -- still valid target

			if( memoryWriteString == nil ) then
				error("Update your copy of MicroMacro to version 1.02!");
			end

			-- freeze TargetPtr
			memoryWriteString(getProc(), addresses.functionTargetPatchAddr, string.rep(string.char(0x90),#addresses.functionTargetBytes));

			-- Target it
			memoryWriteInt(getProc(), player.Address + addresses.pawnTargetPtr_offset, player.TargetPtr);

			-- 'Click'
			if settings.profile.hotkeys.AttackType == "macro" then
				RoMCode("UseSkill(1,1)")
			else
				keyboardPress(settings.profile.hotkeys.AttackType)
			end
			yrest(100)

			-- unfreeze TargetPtr
			memoryWriteString(getProc(), addresses.functionTargetPatchAddr, string.char(unpack(addresses.functionTargetBytes)));

		end
	end
end

function getZoneId()
	local zonechannel = memoryReadRepeat("int", getProc(), addresses.zoneId)
	if zonechannel ~= nil then
		local zone = zonechannel%1000
		return zone, (zonechannel-zone)/1000 + 1 -- zone and channel
	else
		printf("Failed to get zone id\n")
	end
end
-- This function for users is to simplify changing profile after changing character.
function loadProfile(forcedProfile)
   -- convert player name to profile name and check if profile exist
   local load_profile_name;   -- name of profile to load
   if( forcedProfile ) then
      load_profile_name = convertProfileName(forcedProfile);
   else
      load_profile_name = convertProfileName(player.Name);
   end
   player = CPlayer.new();
   settings.load();
   settings.loadProfile(load_profile_name)
   player:update()

   -- Profile onLoad event
   if( type(settings.profile.events.onLoad) == "function" ) then
      local status,err = pcall(settings.profile.events.onLoad);
      if( status == false ) then
         local msg = sprintf("onLoad error: %s", err);
         error(msg);
      end
   end
end

-- Finds a string in another string, normalising it first.
function FindNormalisedString(_name, _string)
	_name = string.lower(_name)
	_string = NormaliseString(_string)

	if string.find(_name,_string) then
		return true
	else
		return false
	end
end
function PointInPoly(vertices, testx, testz )
-- Tells you if a point (testx,testz) is within a polygon represented by a table of points in 'vertices'
	if type(vertices) == "string" then
		if not string.find(vertices,".xml", 1, true) then
			vertices = vertices .. ".xml"
		end
		local filename = getExecutionPath() .. "/waypoints/" .. vertices
		if not fileExists(filename) then
			filename = getExecutionPath() .. "/../romglobal/waypoints/" .. vertices
		end
		local file, err = io.open(filename, "r");
		if file then
			file:close();
			local tmpWPL = CWaypointList();
			tmpWPL:load(filename);
			vertices = table.copy(tmpWPL.Waypoints)
		else
			error("PointInPoly: invalid file name.",0)
		end
	end

	local nvert = #vertices
	local j = nvert
	local c = false
	for i = 1, nvert do
		if ( ((vertices[i].Z > testz) ~= (vertices[j].Z > testz)) and (testx < (vertices[j].X - vertices[i].X) * (testz - vertices[i].Z) / (vertices[j].Z - vertices[i].Z) + vertices[i].X) ) then
			c = not c
		end
		j = i
	end
	return c
end
local currencyMax = {}
function getCurrency(name)
	name = string.lower(name) -- Make lower case
	local noSname = string.match(name,"^(.-)s?$") -- Take off ending 's'

	local group, index, memoffset
	if noSname == "shell" or name == string.lower(getTEXT("SYS_MONEY_TYPE_11")) then
		group, index, memoffset = 1,1,3
	elseif noSname == "energy" or noSname == "eoj" or name == string.lower(getTEXT("SYS_MONEY_TYPE_12")) then
		group, index, memoffset = 1,2,4
	elseif noSname == "dreamland" or noSname == "pioneer sigil" or noSname == "sigil" or name == string.lower(getTEXT("SYS_MONEY_TYPE_10")) then
		group, index, memoffset = 1,3,5
	elseif noSname == "mem" or noSname == "mento" or noSname == "memento" or name == string.lower(getTEXT("SYS_MONEY_TYPE_9")) then
		group, index, memoffset = 2,1,1
	elseif noSname == "proof" or noSname == "pom" or name == string.lower(getTEXT("SYS_MONEY_TYPE_13")) then
		group, index, memoffset = 2,2,2
	elseif noSname == "honor" or name == string.lower(getTEXT("SYS_MONEY_TYPE_4")) then
		group, index, memoffset = 3,1
	elseif noSname == "trial" or noSname == "bott" or name == string.lower(getTEXT("SYS_MONEY_TYPE_8")) then
		group, index, memoffset = 3,2,0
	elseif noSname == "warrior" or noSname == "botw" or name == string.lower(getTEXT("SYS_MONEY_TYPE_14")) then
		group, index, memoffset = 3,3
	else
		print("Invalid currency type. Please use 'shell', 'eoj', 'sigil', 'mem', 'proof', 'honor', 'trial' or 'warrior'.")
		return 0,0
	end

	local amount, limit
	if not memoffset or not currencyMax[memoffset] then
		amount, limit = RoMScript("GetPlayerPointInfo("..group..","..index..",\"\")")
		if memoffset then
			currencyMax[memoffset] = limit
		end
	else
		amount = memoryReadRepeat("uint", getProc(), addresses.charClassInfoBase + addresses.currencyBase_offset + memoffset*4)
		limit = currencyMax[memoffset]
	end

	return amount, limit-amount
end

function tableToString(_table, _formated)
	local tabs=0
	local str = ""

	local function exportstring( s )
		s = string.format( "%q",s )
		-- to replace
		s = string.gsub( s,"\\\n","\\n" )
		s = string.gsub( s,"\r","\\r" )
		s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
		return s
	end

	local function makeString(_val, _name)

		-- first value name
		if type(_name) == "number" then
			_name = "[".. _name .. "]"
		elseif _name ~= nil then
			_name = tostring(_name)
			if type(_name) == "string" and not string.find(_name,"^[%a_][%a%d_]*$") then
				-- Invalid name, surround in quotes
				_name = "[\"".. _name .. "\"]"
			end
		end
		local StringValue = ""
		if _formated == true then
			StringValue = StringValue .. string.rep ("\t",tabs )
		end
		if _name ~= nil then
			StringValue = StringValue .. _name .. "="
		end

		-- Then the value
		local typ = type(_val)
		if typ == "string" then
			StringValue = StringValue .. exportstring(_val)
		elseif typ == "number" or  typ == "boolean" or  typ == "nil" then
			StringValue = StringValue .. tostring(_val)
		elseif typ == "function" or typ == "userdata" then
			StringValue = StringValue .. "\"" .. tostring(_val) .. "\""
		elseif typ == "table" then

			-- First the bracket
			StringValue = StringValue .. "{"
			if _formated == true then
				StringValue = StringValue .. "\n"
			end

			-- Then the indexed values
			tabs = tabs + 1
			local ipairsAdded = {}
			for i,v in ipairs(_val) do
				ipairsAdded[i] = true
				local tmp
				tmp = makeString(v)
				if tmp ~= "" then
					StringValue = StringValue .. tmp .. ","
					if _formated == true then
						StringValue = StringValue .. "\n"
					end
				end
			end

			-- then the values
			for i,v in pairs(_val) do
				if not ipairsAdded[i] then
					local tmp = makeString(v,i)
					if tmp ~= "" then
						StringValue = StringValue .. tmp .. ","
						if _formated == true then
							StringValue = StringValue .. "\n"
						end
					end
				end
			end
			tabs = tabs - 1

			-- Remove last comma
			if _noFormatting and StringValue:sub(#StringValue) == "," then
				StringValue = StringValue:sub(1,#StringValue - 1)
			end

			-- then the end bracket
			if _formated == true then
				StringValue = StringValue .. string.rep ("\t",tabs )
			end
			StringValue = StringValue .. "}"
		end

		return StringValue
	end

	return makeString(_table)
end