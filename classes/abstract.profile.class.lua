CAbstractProfile = class(CBaseObject,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end
	
);


function CAbstractProfile:loadProfile(_name)
	cprintf(cli.yellow,language[186], _name)

	-- Delete old profile settings (if they even exist), restore defaults
	settings.profile = table.copy(settings_default.profile);
	-- search for the directory
	local filename = seekDir("profiles/" .. _name .. ".xml")
	local root =  parser:open(filename);
	local elements = root:getElements();
	
	-- those functions only prepare other functions for the core
	self:loadHotkey();
	self:loadEvents();
	self:loadSkills();
	self:loadFriends();
	self:loadMobs();
	self:loadCore(_name, elements);
	--install and chekc the IGF function
	self:checkMacro(_name)
	--true deaktivates the macro function
	self:setupLanguage(true)
	self:checkIGF(11)
	-- check if automatic targeting is active
	if( settings.profile.options.AUTO_TARGET == false ) then
		cprintf(cli.yellow, "Caution: Automatic targeting is deactivated with option AUTO_TARGET=\"false\"\n");
	end
	-- Remember original combat settings
	originalCombatType = settings.profile.options.COMBAT_TYPE
	originalCombatDistance = settings.profile.options.COMBAT_DISTANCE
	originalCombatRangedPull = settings.profile.options.COMBAT_RANGED_PULL

	
end

function CAbstractProfile:loadHotkey()
	

	self.funcs.loadOptions = function(node)
		local elements = node:getElements();

		for i,v in pairs(elements) do
			settings.profile.options[v:getAttribute("name")] = v:getAttribute("value");
		end
	end

	self.funcs.loadHotkeys = function(node)
		local elements = node:getElements();

		for i,v in pairs(elements) do
			settings.profile.hotkeys[v:getAttribute("name")] = {};
			settings.profile.hotkeys[v:getAttribute("name")].name = v:getAttribute("name");
			settings.profile.hotkeys[v:getAttribute("name")].key = key[v:getAttribute("key")];
			settings.profile.hotkeys[v:getAttribute("name")].modifier = key[v:getAttribute("modifier")];

			if( key[v:getAttribute("key")] == nil ) then
				local err = sprintf(language[127], tostring(v:getAttribute("name")), _name );	-- Please set a valid key
				error(err, 0);
			end

			checkKeySettings(v:getAttribute("name"),
			  v:getAttribute("key"),
			  v:getAttribute("modifier") );

		end
	end
end
function CAbstractProfile:loadEvent()

	self.funcs.loadOnLoadEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onLoad = loadstring(luaCode);
			assert(settings.profile.events.onLoad, sprintf(language[151], "onLoad"));

			if( type(settings.profile.events.onLoad) ~= "function" ) then
				settings.profile.events.onLoad = nil;
			end;
		end
	end

	self.funcs.loadOnDeathEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onDeath = loadstring(luaCode);

			assert(settings.profile.events.onDeath, sprintf(language[151], "onDeath"));

			if( type(settings.profile.events.onDeath) ~= "function" ) then
				settings.profile.events.onDeath = nil;
			end;
		end
	end

	self.funcs.loadOnLeaveCombatEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onLeaveCombat = loadstring(luaCode);
			assert(settings.profile.events.onLeaveCombat, sprintf(language[151], "onLeaveCombat"));

			if( type(settings.profile.events.onLeaveCombat) ~= "function" ) then
				settings.profile.events.onLeaveCombat = nil;
			end;
		end
	end

	self.funcs.loadPreCodeOnElite = function(node)
	local luaCode = node:getValue();
	if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.preCodeOnElite = loadstring(luaCode);
			assert(settings.profile.events.preCodeOnElite, sprintf(language[151], "preCodeOnElite"));

			if( type(settings.profile.events.preCodeOnElite) ~= "function" ) then
				settings.profile.events.preCodeOnElite = nil;
			end;
		end
	end

	self.funcs.loadOnLevelupEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onLevelup = loadstring(luaCode);
			assert(settings.profile.events.onLevelup, sprintf(language[151], "onLevelup"));

			if( type(settings.profile.events.onLevelup) ~= "function" ) then
				settings.profile.events.onLevelup = nil;
			end;
		end
	end

	self.funcs.loadOnPreSkillCastEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onPreSkillCast = loadstring(luaCode);
			assert(settings.profile.events.onPreSkillCast, sprintf(language[151], "onPreSkillCast"));

			if( type(settings.profile.events.onPreSkillCast) ~= "function" ) then
				settings.profile.events.onPreSkillCast = nil;
			end;
		end
	end

	self.funcs.loadOnHarvestEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onHarvest = loadstring(luaCode);
			assert(settings.profile.events.onHarvest, sprintf(language[151], "onHarvest"));

			if( type(settings.profile.events.onHarvest) ~= "function" ) then
				settings.profile.events.onHarvest = nil;
			end;
		end
	end

	self.funcs.loadOnSkillCastEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onSkillCast= loadstring(luaCode);
			assert(settings.profile.events.onSkillCast, sprintf(language[151], "onSkillCast"));

			if( type(settings.profile.events.onSkillCast) ~= "function" ) then
				settings.profile.events.onSkillCast = nil;
			end;
		end
	end

	 self.funcs.loadOnUnstickFailureEvent = function(node)
		local luaCode = node:getValue();
		if( luaCode == nil ) then return; end;

		if( string.len(luaCode) > 0 and string.find(luaCode, "%w") ) then
			settings.profile.events.onUnstickFailure = loadstring(luaCode);
			assert(settings.profile.events.onUnstickFailure, sprintf(language[151], "onUnstickFailure"));

			if( type(settings.profile.events.onUnstickFailure) ~= "function" ) then
				settings.profile.events.onUnstickFailure = nil;
			end;
		end
	end
end


function CAbstractProfile:loadSkills()
	
	self.funcs.loadSkills = function(node)
		local className = string.upper(node:getName())
		local classNum = 0
		if className ~= "SKILLS" then
			className = string.gsub(className,"SKILLS","CLASS")
			classNum = _G[className]
		end
		settings.profile.skillsData[classNum] = {}

		local elements = node:getElements();

		for i,v in pairs(elements) do
			local name, hotkey, modifier
			name = v:getAttribute("name");
--			hotkey = key[v:getAttribute("hotkey")];
			modifier = key[v:getAttribute("modifier")];

			-- using the MACRO key as hotkey is also a valid key
			if( string.upper( tostring(v:getAttribute("hotkey")) ) == "MACRO" ) then
				hotkey = "MACRO";						-- set MACRO as hotkey
			else
				hotkey = key[v:getAttribute("hotkey")];	-- read the virtual key numer
			end

			-- Over-ride attributes
			local priority, maxhpper, maxenergyper , minmenergyper, cooldown, inbattle, pullonly, maxuse, autouse, rebuffcut;
			local reqbuffname, reqbuffcount, reqbufftarget, nobuffname, nobuffcount, nobufftarget, mobcount, minrange
			local enemydodge, enemycritical, playerblock, playerdodge, playerparalyzed, playerdead, playeritem, playerstate 
			
			priority = v:getAttribute("priority");
			maxhpper = tonumber((string.gsub(v:getAttribute("hpper") or "","!","-")));
			targetmaxhpper = tonumber((string.gsub(v:getAttribute("targethpper") or "","!","-")));
			targetmaxhp = tonumber((string.gsub(v:getAttribute("targethp") or "","!","-")));
			maxenergyper = v:getAttribute("maxenergyper");
			minmenergyper = v:getAttribute("minenergyper");
			cooldown = tonumber(v:getAttribute("cooldown"));
			inbattle = v:getAttribute("inbattle");
			pullonly = v:getAttribute("pullonly");
			maxuse = tonumber(v:getAttribute("maxuse"));
			rebuffcut = tonumber(v:getAttribute("rebuffcut"));
			reqbuffcount = tonumber(v:getAttribute("reqbuffcount"));
			reqbufftarget = v:getAttribute("reqbufftarget");
			reqbuffname = v:getAttribute("reqbuffname");
			nobuffcount = tonumber(v:getAttribute("nobuffcount"));
			nobufftarget = v:getAttribute("nobufftarget");
			nobuffname = v:getAttribute("nobuffname");
			autouse = v:getAttribute("autouse");
			mobcount = v:getAttribute("mobcount");
			minrange = v:getAttribute("minrange");
			
				--some player states + general buffs and debuffs goes extra
			enemydodge = v:getAttribute("enemydodge")
			enemycritical = v:getAttribute("enemycritical")
			playerblock = v:getAttribute("playerblock")
			playerdodge = v:getAttribute("playerdodge")
			playerparalyzed	= v:getAttribute("playerparalyzed")
			playerdead = v:getAttribute("playerdead")
			playeritem =  v:getAttribute("playeritem") --item or itemtype
			playerstate =  v:getAttribute("playerstate") or "" -- everything which don't fit in with the rest

			-- check if 'wrong' options are set
			if( v:getAttribute("mana")      or
			    v:getAttribute("rage")      or
			    v:getAttribute("energy")    or
			    v:getAttribute("focus")      or
			    v:getAttribute("range")     or
			    v:getAttribute("type")      or
			    v:getAttribute("target")    or
				v:getAttribute("energytype") or 
				v:getAttribute("energyvalue") or
			    v:getAttribute("casttime") ) then
					local msg = sprintf(language[128], name, _name);	-- are no valid options for your skill
					error(msg, 0);
			end;

			if( name == nil) then
				local msg = sprintf(language[130], _name);	-- empty\' skill name
				error(msg, 0);
			end;

			if( inbattle ~= nil ) then
				if( inbattle == "true" or
					inbattle == true ) then
					inbattle = true;
				elseif( inbattle == "false"  or
					inbattle == false ) then
					inbattle = false;
				else
					local msg = sprintf(language[131], inbattle, name, _name);	-- wrong option inbattle

					error(msg, 0);
				end;
			end

			if( pullonly ~= nil ) then
				if( pullonly == "true" or
					pullonly == true ) then
					pullonly = true;
				else
					local msg = sprintf(language[132], pullonly, name, _name);	-- wrong option pullonly

					error(msg, 0);
				end;
			end

			if( level == nil or level < 1 ) then
				level = 1;
			end

			local baseskill = database.skills[name];
			if( not baseskill ) then
				local err = sprintf("ERROR: \'%s\' is not defined in the database!", name);
				error(err, 0);
			end

			local tmp = CSkill(database.skills[name]);
			tmp.hotkey = hotkey;
			tmp.modifier = modifier;

			if (tmp.hotkey == "MACRO" or tmp.hotkey == "" or tmp.hotkey == nil ) and tmp.Id == 0 then
				local msg = sprintf(language[158],tmp.Name);    -- Can't use "MACRO" without skill id.
				error(msg,0);
			end

			if (reqbuffname and not reqbufftarget) or (not reqbuffname and reqbufftarget) then
				local msg = sprintf(language[154], name, _name);	-- need to define both
				error(msg, 0);
			end

			if (nobuffname and not nobufftarget) or (not nobuffname and nobufftarget) then
				local msg = sprintf(language[155], name, _name);	-- need to define both
				error(msg, 0);
			end
		
			if reqbufftarget ~= nil and reqbufftarget ~= "target" and reqbufftarget ~="player" then
				local msg = sprintf(language[156], reqbufftarget, name, _name);	-- needs to be 'target' or 'player'
				error(msg, 0);
			end

			if nobufftarget ~= nil and nobufftarget ~= "target" and nobufftarget ~="player" then
				local msg = sprintf(language[157], nobufftarget, name, _name);	-- needs to be 'target' or 'player'
				error(msg, 0);
			end

			if minrange and minrange > tmp.Range then
				local msg = sprintf(language[189], name, minrange, tmp.Range)
				cprintf(cli.yellow, msg)
			end

			if( toggleable ) then tmp.Toggleable = toggleable; end;
			if( priority ) then tmp.priority = priority; end
			if( targetmaxhpper ) then tmp.TargetMaxHpPer = targetmaxhpper; end;
			if( targetmaxhp ) then tmp.TargetMaxHp = targetmaxhp; end;
			if( maxhpper ) then tmp.MaxHpPer = maxhpper; end;
			if( maxmanaper ) then tmp.MaxManaPer = maxmanaper; end;
			if( cooldown ) then tmp.Cooldown = cooldown; end;
			if( inbattle ~= nil ) then tmp.InBattle = inbattle; end;
			if( pullonly == true ) then tmp.pullonly = pullonly; end;
			if( maxuse ) then tmp.maxuse = maxuse; end;
			if( maxenergyper ) then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(maxenergyper, "[^,]+") do
				
					t[i] = tonumber(token);
					i= i + 1;
				end
			
				tmp.MaxEnergyPer = t;
			end;
			if(minenergyper) then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(minenergyper, "[^,]+") do
				
					t[i] = tonumber(token);
					i= i + 1;
				end
			
				tmp.MinEnergyPer = t;
		
			end;
			if(reqbuffcount and reqbuffcount ~= "" ) then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(reqbuffcount, "[^,]+") do
				
					t[i] = tonumber(token);
					i= i + 1;
				end
			
				tmp.ReqBuffCount = t;
			end;
		
			if(reqbuffname and reqbuffname ~= "") then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(reqbuffname, "[^,]+") do
				
					t[i] = token;
					i= i + 1;
				end
			
				tmp.ReqBuffName = t 
			end;
			if(nobuffcount and nobuffcount ~="" ) then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(nobuffcount, "[^,]+") do
				
					t[i] = tonumber(token);
					i= i + 1;
				end
			
				tmp.NoBuffCount = t;
			end;
	
			if(nobuffname and nobuffname ~= "") then 
				local t = {}
				local i = 1;
				
				for token in string.gmatch(nobuffname, "[^,]+") do
				
					t[i] = token;
					i= i + 1;
				end
			
				tmp.NoBuffName = t;
			end;
			
			if( autouse ~= nil ) then tmp.AutoUse = (autouse == true) ; end;
			if( mobcount ) then tmp.MobCount = mobcount; end;
			if( minrange ) then tmp.MinRange = minrange; end;
			
			if( nobufftarget ) then tmp.NoBuffTarget = nobufftarget; end;
			if( reqbufftarget ) then tmp.ReqBuffTarget = reqbufftarget; end;
			table.insert(settings.profile.skillsData[classNum], tmp);

		end
	end
end

function CAbstractProfile:loadFriends()
	self.funcs.loadFriends = function(node)
		local elements = node:getElements();

		for i,v in pairs(elements) do

			local name = v:getAttribute("name");

			if( name ) then name = trim(name); end;

			if( name ) then

				-- fix, because getAttribute seems not to recognize the escape characters
				-- for special ASCII characters
				name = string.gsub (name, "\\132", string.char(132));	-- ä
				name = string.gsub (name, "\\142", string.char(142));	-- Ä
				name = string.gsub (name, "\\148", string.char(148));	-- ö
				name = string.gsub (name, "\\153", string.char(153));	-- Ö
				name = string.gsub (name, "\\129", string.char(129));	-- ü
				name = string.gsub (name, "\\154", string.char(154));	-- Ü
				name = string.gsub (name, "\\225", string.char(225));	-- ß

				table.insert(settings.profile.friends, name);
			end
		end
	end
end
function CAbstractProfile:loadMobs()
	local loadMobs = function(node)
		local elements = node:getElements();

		for i,v in pairs(elements) do

			local name = v:getAttribute("name");

			if( name ) then name = trim(name); end;

			if( name ) then

				-- fix, because getAttribute seems not to recognize the escape characters
				-- for special ASCII characters
				name = string.gsub (name, "\\132", string.char(132));	-- ä
				name = string.gsub (name, "\\142", string.char(142));	-- Ä
				name = string.gsub (name, "\\148", string.char(148));	-- ö
				name = string.gsub (name, "\\153", string.char(153));	-- Ö
				name = string.gsub (name, "\\129", string.char(129));	-- ü
				name = string.gsub (name, "\\154", string.char(154));	-- Ü
				name = string.gsub (name, "\\225", string.char(225));	-- ß

				table.insert(settings.profile.mobs, name);
			end
		end
	end
end
function CAbstractProfile:loadCore(_name, elements)
	local hf_temp = _name;	-- remember profile name shortly

	for i,v in pairs(elements) do
		local name = v:getName();
		if( string.lower(name) == "options" ) then
			loadOptions(v);
		elseif( string.lower(name) == "hotkeys" ) then
			loadHotkeys(v);
		elseif( string.lower(name) == "skills" ) then
			loadSkills(v);
		elseif( string.lower(name) == "friends" ) then
			loadFriends(v);
		elseif( string.lower(name) == "mobs" ) then
			loadMobs(v);
		elseif( string.lower(name) == "onload" ) then
			loadOnLoadEvent(v);
		elseif( string.lower(name) == "ondeath" ) then
			loadOnDeathEvent(v);
		elseif( string.lower(name) == "onleavecombat" ) then
			loadOnLeaveCombatEvent(v);
		elseif( string.lower(name) == "precodeonelite" ) then
			loadPreCodeOnElite(v);
		elseif( string.lower(name) == "onlevelup" ) then
			loadOnLevelupEvent(v);
		elseif( string.lower(name) == "onskillcast" ) then
			loadOnSkillCastEvent(v);
		elseif( string.lower(name) == "onharvest" ) then
			loadOnHarvestEvent(v);
		elseif( string.lower(name) == "onunstickfailure" ) then
			loadonUnstickFailureEvent(v);
		elseif( string.lower(name) == "onpreskillcast" ) then
			loadOnPreSkillCastEvent(v);
		elseif( string.lower(name) == "skills_warrior"  or
			string.lower(name) == "skills_scout"  or
			string.lower(name) == "skills_rogue"  or
			string.lower(name) == "skills_mage"  or
			string.lower(name) == "skills_priest"  or
			string.lower(name) == "skills_knight"  or
			string.lower(name) == "skills_warden"  or
			string.lower(name) == "skills_druid"  or
			string.lower(name) == "skills_warlock"  or
			string.lower(name) == "skills_champion" ) then
				loadSkills(v);
		else		-- warning for other stuff and misspellings
			if ( string.lower(name) ~= "skills_warrior"     and
			     string.lower(name) ~= "skills_scout"       and
		 	     string.lower(name) ~= "skills_rogue"       and
	 		     string.lower(name) ~= "skills_mage"        and
			     string.lower(name) ~= "skills_priest"      and
			     string.lower(name) ~= "skills_knight"      and
			     string.lower(name) ~= "skills_warden"      and
			     string.lower(name) ~= "skills_druid"       and
				 string.lower(name) ~= "skills_warlock"     and
				 string.lower(name) ~= "skills_champion" ) then
				cprintf(cli.yellow, tostring(language[60]), string.lower(tostring(name)),
					tostring(hf_temp));
			end;
		end
	end
end
function CAbstractProfile:checkMacro(_name, notactiv)
	if(notactiv)then
		return;
	end
	-- checks for MACRO hotkey
	-- print error if new macro option isn't defined
	if( not settings.profile.hotkeys.MACRO ) then
		cprintf(cli.yellow, language[900]);
		cprintf(cli.yellow, language[901]);
		cprintf(cli.yellow, language[902]);
		cprintf(cli.yellow, language[903]);
		cprintf(cli.yellow, language[904], "VK_0"); -- TODO: Change VK_0 to the actual hotkey we should use
		local msg = sprintf(language[905], _name);
		error(msg, 0);
	end

	-- Setup the macros and action key.
	setupMacros()

	-- check if new macro option is working / ingame macro defined and assigned
	-- check it with a function with defined return values
	settings.options.DEBUGGING_MACRO = true;
	cprintf(cli.blue, "Testing 'ingamefunctions' macro. If it gets stuck here, please update the 'ingamefunctions' by copying the 'ingamefunctions' folder from 'rom/devtools' to the games 'interface/addons' folder.")
	local hf_return = RoMScript("1234;ChatFrame1:AddMessage(\"MACRO test: send value 1234 to macro place 2\");");
	if( hf_return ~= 1234 ) then	-- return values not found
		cprintf(cli.yellow, language[906] );	-- Define ingame an empty macro

		if ( settings.profile.hotkeys.MACRO.key) then
			hf_temp = getKeyName(settings.profile.hotkeys.MACRO.key);
		else
			local hf_temp ="<UNKNOWN>";	-- if ignore, key must not be set, so give value
		end

		local msg = sprintf(language[904], hf_temp );

		error(msg, 0);
	else								-- return values found, clear it and send message
		cprintf(cli.green, "MACRO Test: ok\n" );
		RoMCode("ChatFrame1:AddMessage(\"MACRO test: successful\");");	-- overwrite values
	end
	settings.options.DEBUGGING_MACRO = false;

end
function CAbstractProfile:setupLanguage(_language)
	
	-- we can force a language since we don't have this luxury in other games.
	
	if( not _language )then
		-- MACRO is working, we can automaticly reset the langugae
		-- remember game client language
		local hf_langu = RoMScript("GetLanguage();");
		if( not hf_langu ) then
			local msg = sprintf(language[62]);	-- Error while reading the language settings
			cprintf(cli.yellow, msg);
			hf_langu = "ENEU";
		end
		bot.ClientLanguage = hf_langu;	-- remember clients language
	end

	-- reset bot language to clients language
	if( settings.options.USE_CLIENT_LANGUAGE ) then
		local hf_language;
		if( bot.ClientLanguage == "DE" ) then
			hf_language = "deutsch";
		elseif(bot.ClientLanguage  == "FR" ) then
			hf_language = "french";
		elseif(bot.ClientLanguage  == "RU" ) then
			hf_language = "russian";
		elseif(bot.ClientLanguage == "PL" ) then
			hf_language = "polish";
		else
			hf_language = "english";
		end

		if( settings.options.LANGUAGE ~= hf_language ) then		-- load new language?

			local function setLanguage(_name)
				include("/language/" .. _name .. ".lua");
			end

			local lang_base = {};

			for i,v in pairs(language) do lang_base[i] = v; end;	-- remember current language value to fill gaps with that

			setLanguage(hf_language);
			for i,v in pairs(lang_base) do
				if( language[i] == nil ) then
					language[i] = v;
				end
			end;
			lang_base = nil; -- Not needed anymore, destroy it.
			logMessage("Load Language according to client language: " .. hf_language);

		end

	end
end
function CAbstractProfile:checkIGF(ver)
	-- now we can do all other setting checks

	-- check if igf addon is active
	local igf_version = RoMScript("IGF_INSTALLED")
	 -- Change this value to match the value in "ingamefunctions.lua".
	 -- moved upwards
	local current_version = ver
	if igf_version then
		bot.IgfAddon = true;
		bot.IgfVersion = igf_version
		-- Check version
		if igf_version < current_version then
			error(string.format(language[1006], current_version, igf_version), 0)
		end
	else
		error(language[1004], 0)	-- Ingamefunctions addon (igf) is not installed
	end
end