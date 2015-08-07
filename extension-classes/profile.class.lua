CProfile = class(CAbstractProfile,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end
	
);
function CProfile:loadProfile(_name)
	cprintf(cli.yellow,language[186], _name)
	--TODO: move it to the database
	
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
	--install and check the IGF function
	self:checkMacro(_name, not bot.UseMacro)
	--true deaktivates the macro function
	self:setupLanguage( not bot.UseMacro)
	
	self:checkIGF( bot.Ifgversion )
	-- check if automatic targeting is active
	if( settings.profile.options.AUTO_TARGET == false ) then
		cprintf(cli.yellow, "Caution: Automatic targeting is deactivated with option AUTO_TARGET=\"false\"\n");
	end
	-- Remember original combat settings
	originalCombatType = settings.profile.options.COMBAT_TYPE
	originalCombatDistance = settings.profile.options.COMBAT_DISTANCE
	originalCombatRangedPull = settings.profile.options.COMBAT_RANGED_PULL

	
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