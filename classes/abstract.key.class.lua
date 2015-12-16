CAbstractKeys = class(CBaseObject,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end

);
function CAbstractKeys:loadKeys()
	local filename = seekDir("settings.xml");

	self:loadSettings(filename, bot.Gamedirectory, bot.Keybindfile);
end
function CAbstractKeys:checkKeySettings( _name, _key, _modifier)
	-- args are the VK in stringform like "VK_CONTROL", "VK_J", ..

	local hf_check_where;
	if( bindings ) then	-- keys are from bindings.txt
		hf_check_where = language[141];		-- Datei settings.xml
	else
		hf_check_where = language[140];		-- Ingame -> System -> Tastenbelegung
	end

	local msg = nil;
	-- no empty keys pls
	if( _key == nil) then
		msg = sprintf(language[115], _name);	-- key for \'%s\' is empty!
		msg = msg .. hf_check_where;
	end

	-- check if all keys are valid virtual keys (VK)
	if( _key ) then
		if( key[_key]  == nil  and
			string.upper(_key) ~= "MACRO" ) then	-- hotekey MACRO is a special case / it's not a virtual key
			msg = sprintf(language[116], _key, _name);	-- The hotkey ... is not a valid key
			msg = msg .. hf_check_where;
		end
	end;

	-- no modifiers allowed at the moment
	if( _modifier ) then
		if( key[_modifier]  == nil ) then
			msg = sprintf(language[117], _modifier, _name);	-- The modifier ... is not a valid key
			msg = msg .. hf_check_where;
		end
	end;

	-- now we check for double key settings
	-- we translate the strings "VK..." to the VK numbers
	if( string.upper(_key) ~= "MACRO" ) then
		_key = key[_key];
	end
	_modifier = key[_modifier];

	-- check the using of modifiers
	-- they are not usable at the moment

	-- error output
	if( msg ~= nil) then
		-- only a warning for TARGET_FRIEND / else an error
		if(_name == "TARGET_FRIEND") then
			cprintf(cli.yellow, msg .. language[119]);	-- can't use the player:target_NPC() function
		else
			error(msg, 0);
		end
	end

	-- check for double key settings
	for i,v in pairs(check_keys) do
		if( v.name ~= _nil and	-- empty entries from deleted settings.xml entries
			v.key == _key  and
			string.upper(_key) ~= "MACRO" and	-- hotkey MACRO is allowed to set more then once
			v.modifier == _modifier ) then
			local modname;

			if( v.modifier ) then
				modname = getKeyName(v.modifier).."+";
			else
				modname = "";
			end;

			local errstr = sprintf(language[121],	-- assigned the key \'%s%s\' double
				modname,
				getKeyName(v.key),
				v.name, _name) ..
			hf_check_where;
			error(errstr, 0);
		end
	end;

	check_keys[_name] = {};
	check_keys[_name].name = _name;
	check_keys[_name].key = _key;
	check_keys[_name].modifier = _modifier;
end


function CAbstractKeys:settingsPrintKeys()
	-- That function prints the loaded key settings to the MM window and to the log

	local msg;
	msg ="QUICK_TURN = "..tostring(settings.profile.options.QUICK_TURN);	-- we wander around
	logMessage(msg);		-- log keyboard settings

	if( bindings ) then		-- we read from bindings.txt
		msg = sprintf(language[167], "bindings.txt");	-- Keyboard settings are from
	else				-- we read settings.xml
		msg = sprintf(language[167], "settings.xml");	-- Keyboard settings are from
	end

	--	cprintf(cli.green, msg.."\n");	-- Keyboard settings are from
	logMessage(msg);		-- log keyboard settings

	for i,v in pairs(check_keys) do

		if(v.name) then

			msg = string.sub(v.name.."                               ", 1, 30);	-- function name

			local modname;
			if( v.modifier ) then
				modname = getKeyName(v.modifier).."+";	-- modifier name
			else
				modname = "";
			end;

			local keyname;
			if( string.upper(v.key) == "MACRO" ) then
				keyname = "MACRO";
			else
				keyname = getKeyName(v.key);
			end

			msg = msg..modname..keyname;	-- add key name
			--			printf(msg.."\n");			-- print line
			logMessage(msg);			-- log keyboard settings

		end;
	end;

end


function CAbstractKeys:loadSettings(filename, subdirectory, external_file)

	local root =  parser:open(filename);
	local elements = root:getElements();

	check_keys = { };	-- clear table, because of restart from createpath.lua

	-- Specific to loading the hotkeys section of the file
	local loadHotkeys = function (node)
		local elements = node:getElements();
		for i,v in pairs(elements) do
			-- If the hotkey doesn't exist, create it.
			settings.hotkeys[ v:getAttribute("description") ] = { };
			settings.hotkeys[ v:getAttribute("description") ].key = key[v:getAttribute("key")];
			settings.hotkeys[ v:getAttribute("description") ].modifier = key[v:getAttribute("modifier")];

			if( key[v:getAttribute("key")] == nil ) then
				local err = sprintf(language[122],	-- does not have a valid hotkey!
					v:getAttribute("description"));
				error(err, 0);
			end

			self:checkKeySettings( v:getAttribute("description"),
				v:getAttribute("key"),
				v:getAttribute("modifier") );
		end
	end

	local loadOptions = function (node)
		local elements = node:getElements();
		for i,v in pairs(elements) do
			settings.options[ v:getAttribute("name") ] = v:getAttribute("value");
		end
	end

	-- Load RoM keyboard bindings.txt file
	local function load_RoM_bindings_txt()
		local filename, file;

		local userprofilePath = os.getenv("USERPROFILE");
		local documentPaths = {
			userprofilePath .. "\\My Documents\\" .. "Runes of Magic", -- English
			userprofilePath .. "\\Eigene Dateien\\" .. "Runes of Magic", -- German
			userprofilePath .. "\\Mes Documents\\" .. "Runes of Magic", -- French
			userprofilePath .. "\\Omat tiedostot\\" .. "Runes of Magic", -- Finish
			userprofilePath .. "\\Belgelerim\\" .. "Runes of Magic", -- Turkish
			userprofilePath .. "\\Mina Dokument\\" .. "Runes of Magic", -- Swedish
			userprofilePath .. "\\Dokumenter\\" .. "Runes of Magic", -- Danish
			userprofilePath .. "\\Documenti\\" .. "Runes of Magic", -- Italian
			userprofilePath .. "\\Mijn documenten\\" .. "Runes of Magic", -- Dutch
			userprofilePath .. "\\Moje dokumenty\\" .. "Runes of Magic", -- Polish
			userprofilePath .. "\\Mis documentos\\" .. "Runes of Magic", -- Spanish
			userprofilePath .. "\\Os Meus Documentos\\" .. "Runes of Magic", -- Portuguese
		};

		-- Use a user-specified path from settings.xml
		if( settings.options.ROMDATA_PATH ) then
			table.insert(documentPaths, settings.options.ROMDATA_PATH);
		end

		-- Select the first path that exists
		for i,v in pairs(documentPaths) do
			if( string.sub(v, -1 ) ~= "\\" and string.sub(v, -1 ) ~= "/" ) then
				v = v .. "\\"; -- Append the trailing backslash if necessary.
			end

			local filename = v..external_file;
			if( fileExists(filename) ) then
				file = io.open(filename, "r");
				local tmp = filename;
				cprintf(cli.green, language[123], filename);	-- read the hotkey settings from your bindings.txt
			end
		end

		-- If we wern't able to locate a document path, return.
		if( file == nil ) then
			return;
		end

		-- delete hotkeys from settings.xml in check table to avoid double entries / wrong checks
		check_keys["MOVE_FORWARD"] = nil;
		check_keys["MOVE_BACKWARD"] = nil;
		check_keys["ROTATE_LEFT"] = nil;
		check_keys["ROTATE_RIGHT"] = nil;
		check_keys["STRAFF_LEFT"] = nil;
		check_keys["STRAFF_RIGHT"] = nil;
		check_keys["JUMP"] = nil;
		check_keys["TARGET"] = nil;
		check_keys["TARGET_FRIEND"] = nil;
		check_keys["ESCAPE"] = nil;

		-- Load bindings.txt into own table structure
		bindings = { name = { } };
		-- read the lines in table 'lines'
		for line in file:lines() do
			for name, key1, key2 in string.gmatch(line, "(%w*)%s([%w+]*)%s*([%w+]*)") do
				bindings[name] = {};
				bindings[name].key1 = key1;
				bindings[name].key2 = key2;

			--settings.hotkeys[name].key =
			end
		end

		local function bindHotkey(bindingName)
			local links = { -- Links forward binding names to hotkey names
				MOVEFORWARD = "MOVE_FORWARD",
				MOVEBACKWARD = "MOVE_BACKWARD",
				TURNLEFT = "ROTATE_LEFT",
				TURNRIGHT = "ROTATE_RIGHT",
				STRAFELEFT = "STRAFF_LEFT",
				STRAFERIGHT = "STRAFF_RIGHT",
				JUMP = "JUMP",
				TARGETNEARESTENEMY = "TARGET",
				TARGETNEARESTFRIEND = "TARGET_FRIEND",
				TOGGLEGAMEMENU = "ESCAPE",
			};

			local hotkeyName = bindingName;
			if(links[bindingName] ~= nil) then
				hotkeyName = links[bindingName];
			end;


			if( bindings[bindingName] ~= nil ) then
				if( bindings[bindingName].key1 ~= nil ) then
					-- Fix key names
					bindings[bindingName].key1 = string.gsub(bindings[bindingName].key1, "CTRL", "CONTROL");

					if( string.find(bindings[bindingName].key1, '+') ) then
						local parts = explode(bindings[bindingName].key1, '+');
						-- parts[1] = modifier
						-- parts[2] = key

						settings.hotkeys[hotkeyName].key = key["VK_" .. parts[2]];
						settings.hotkeys[hotkeyName].modifier = key["VK_" .. parts[1]];
						self:checkKeySettings(hotkeyName, "VK_" .. parts[2], "VK_" .. parts[1] );
					else
						settings.hotkeys[hotkeyName].key = key["VK_" .. bindings[bindingName].key1];
						self:checkKeySettings(hotkeyName, "VK_" .. bindings[bindingName].key1 );
					end

				else
					local err = sprintf(language[124], bindingName);	-- no ingame hotkey for
					error(err, 0);
				end
			end
		end

		bindHotkey("MOVEFORWARD");
		bindHotkey("MOVEBACKWARD");
		bindHotkey("TURNLEFT");
		bindHotkey("TURNRIGHT");
		bindHotkey("STRAFELEFT");
		bindHotkey("STRAFERIGHT");
		bindHotkey("JUMP");
		bindHotkey("TARGETNEARESTENEMY");
		bindHotkey("TARGETNEARESTFRIEND");
		bindHotkey("TOGGLEGAMEMENU");
	end

	-- check ingame settings
	-- only if we can find the bindings.txt file
	local function check_ingame_settings( _name, _ingame_key)
		-- no more needed, because we take the keys from the file if we found the file

		if( not bindings ) then		-- no bindings.txt file loaded
			return
		end;

		if( settings.hotkeys[_name].key ~= key["VK_"..bindings[_ingame_key].key1] and
			settings.hotkeys[_name].key ~= key["VK_"..bindings[_ingame_key].key2] ) then
			local msg = sprintf(language[125], _name);	-- settings.xml don't match your RoM ingame
			error(msg, 0);
		end
	end


	function checkHotkeys(_name, _ingame_key)
		if( not settings.hotkeys[_name] ) then
			error(language[126] .. _name, 0);	-- Global hotkey not set
		end

		-- check if settings.lua hotkeys match the RoM ingame settings
		-- check_ingame_settings( _name, _ingame_key);
	end


	for i,v in pairs(elements) do
		local name = v:getName();

		if( string.lower(name) == "hotkeys" ) then
			loadHotkeys(v);
		elseif( string.lower(name) == "options" ) then
			loadOptions(v);
		end
	end


	-- TODO: don't work at the moment, becaus MACRO hotkey not available at this time
	-- will first be available after reading profile file
	-- read language from client if not set in settings.xml
	--	if( not settings.options.LANGUAGE ) then
	--		local hf_language = RoMScript("GetLanguage();");	-- read clients language
	--		if( hf_language == "DE" ) then
	--			settings.options.LANGUAGE = "deutsch";
	--		elseif(hf_language == "ENEU" ) then
	--			settings.options.LANGUAGE = "english";
	--		elseif(hf_language == "FR" ) then
	--			settings.options.LANGUAGE = "french";
	--		else
	--			settings.options.LANGUAGE = "english";
	--		end
	--	end

	-- Load language files
	-- Load "english" first, to fill in any gaps in the users' set language.
	local function setLanguage(name)
		include("/language/" .. name .. ".lua");
	end

	local lang_base = {};
	setLanguage("english");
	for i,v in pairs(language) do lang_base[i] = v; end;
	setLanguage(settings.options.LANGUAGE);
	for i,v in pairs(lang_base) do
		if( language[i] == nil ) then
			language[i] = v;
		end
	end;
	lang_base = nil; -- Not needed anymore, destroy it.
	logMessage("Language: " .. settings.options.LANGUAGE);


	load_RoM_bindings_txt();	-- read bindings.txt from RoM user folder

	-- Check to make sure everything important is set
	--           bot hotkey name    RoM ingame key name
	checkHotkeys("MOVE_FORWARD",   "MOVEFORWARD");
	checkHotkeys("MOVE_BACKWARD",  "MOVEBACKWARD");
	checkHotkeys("ROTATE_LEFT",    "TURNLEFT");
	checkHotkeys("ROTATE_RIGHT",   "TURNRIGHT");
	checkHotkeys("STRAFF_LEFT",    "STRAFELEFT");
	checkHotkeys("STRAFF_RIGHT",   "STRAFERIGHT");
	checkHotkeys("JUMP",           "JUMP");
	checkHotkeys("TARGET",         "TARGETNEARESTENEMY");
	checkHotkeys("TARGET_FRIEND",  "TARGETNEARESTFRIEND");
	checkHotkeys("ESCAPE",         "TOGGLEGAMEMENU");

end
