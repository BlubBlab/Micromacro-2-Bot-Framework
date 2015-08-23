CAbstractSkillSet = class(CBaseObject,
	function (self, copyfrom)
		self.funcs = {};
		if( type(copyfrom) == "table" ) then
			self.funcs = copyfrom.funcs;
		end
	end
	
);


-- last function
function CAbstractSkillSet:loadSkillSet(class)
	-- return if player not initialized yet.
	if not player then return end

	local skillSort = function(tab1, tab2)
		if( tab2.priority < tab1.priority ) then
			return true;
		end;

		return false;
	end

	settings.profile.skills = {}
	if type(settings.profile.skillsData[0]) == "table" then
		for k,v in pairs(settings.profile.skillsData[0]) do -- general skills
			table.insert(settings.profile.skills, v)
		end
	end
	if type(settings.profile.skillsData[class]) == "table" then
		for k,v in pairs(settings.profile.skillsData[class]) do -- class skills
			table.insert(settings.profile.skills, v)
		end
	end

	table.sort(settings.profile.skills, skillSort);

	-- Setup the macros and action key.
	if settings.profile.hotkeys.MACRO ~= nil and UseMacro then
		setupMacros()
	end

	-- Updates skill availability and some values(Id,Level,aslevel,TPToLevel,Mana,Rage,Focus,Energy,Consumable,ConsumableNumber)
	if(bot.UseAutoUpdateSkills )then
		self:updateSkillsAvailability()
	end

	-- Check if the player has any ranged damage skills
	local rangedSkills = false;
	local realRange
	equipment.BagSlot[10]:update() -- Update bow range.
	for i,v in pairs(settings.profile.skills) do
		if v.AddWeaponRange == true then
			realRange = v.Range + equipment.BagSlot[10].Range
		else
			realRange = v.Range
		end

		if( realRange > 100  and
			( v.Type == STYPE_DAMAGE or
			  v.Type == STYPE_DOT ) and
			  v.Available) then
			rangedSkills = true;
			printf(language[176], v.Name);		-- Ranged skill found
			break;
		end
	end

	settings.profile.options.COMBAT_TYPE = originalCombatType
	settings.profile.options.COMBAT_DISTANCE = originalCombatDistance
	settings.profile.options.COMBAT_RANGED_PULL = originalCombatRangedPull

	if( rangedSkills == false and settings.profile.options.COMBAT_RANGED_PULL ) then
		cprintf(cli.yellow, language[200]); -- No ranged skills. Turning COMBAT_RANGED_PULL off.
		settings.profile.options.COMBAT_RANGED_PULL = false;
	end

	-- default combat type if not in profile defined
	if( settings.profile.options.COMBAT_TYPE ~= "ranged" and
	    settings.profile.options.COMBAT_TYPE ~= "melee" ) then
		if( player.Class1 == CLASS_WARRIOR or
		    player.Class1 == CLASS_ROGUE   or
		    player.Class1 == CLASS_WARDEN  or
		    player.Class1 == CLASS_KNIGHT  or
			player.Class1 == CLASS_CHAMPION  ) then
			settings.profile.options.COMBAT_TYPE  = "melee";
		elseif(
		    player.Class1 == CLASS_PRIEST  or
		    player.Class1 == CLASS_SCOUT   or
		    player.Class1 == CLASS_DRUID   or
		    player.Class1 == CLASS_MAGE    or
			player.Class1 == CLASS_WARLOCK ) then
			settings.profile.options.COMBAT_TYPE  = "ranged";
		else
			error("undefined player.Class1 in settings.lua", 0);
		end;
	end

	-- check if range attack range and combat distance fit together
	local best_range = 0;
	for i,v in pairs(settings.profile.skills) do
		if v.AddWeaponRange == true then
			realRange = v.Range + equipment.BagSlot[10].Range
		else
			realRange = v.Range
		end

		if( realRange > best_range and
			( v.Type == STYPE_DAMAGE or
			  v.Type == STYPE_DOT ) and
			  v.Available) then
			best_range = realRange;
		end
	end

	if best_range < 50 then best_range = 50 end

	-- check is combat distance is greater then maximum ranged attack
	if ( settings.profile.options.COMBAT_DISTANCE == nil or
		best_range < settings.profile.options.COMBAT_DISTANCE) then --and
		cprintf(cli.yellow, language[179], settings.profile.options.COMBAT_DISTANCE or 0, best_range);	-- Maximum range of range attack skills is lesser
		settings.profile.options.COMBAT_DISTANCE = best_range
	end
end

-- This is a function deeply bund into ROM you have to overwrite it if you want something like this.
function CAbstractSkillSet:updateSkillsAvailability()
	-- Adds or updates skills values;
	--   Id
	--   TPToLevel
	--   Level
	--   aslevel
	--   Available
	--   Mana
	--   Rage
	--   Focus
	--   Energy
	--   Consumable
	--   ConsumableNumber

	-- First collect tab skill info
	local tabData = GetSkillBookData({2,3,4}) -- tabs of interest 2,3 and 4

	-- Then collect item set skills
	for num = 1, 5 do -- 5 possible enabled item set skills
		local id = memoryReadInt(getProc(), addresses.itemSetSkillsBase + (num - 1)*4)
		if id ~= 0 then
			local address = GetItemAddress(id)
			local name = GetIdName(id)
			if name ~= nil and name ~= "" and address ~= nil then
				local aslevel = memoryReadInt(getProc(), address + addresses.skillItemSetAsLevel_offset)

				-- Get power and consumables
				local baseAddress = GetItemAddress(id)
				local mana, rage, focus, energy, consumable, consumablenumber, psi
				for count = 0, 1 do
					local uses = memoryReadRepeat("int", getProc(), baseAddress + (8 * count) + addresses.skillUsesBase_offset)
					if uses == 0 then
						break
					end
					local usesnum = memoryReadRepeat("int", getProc(), baseAddress + (8 * count) + addresses.skillUsesBase_offset + 4)
					if uses == SKILLUSES_MANA then
						mana = usesnum
					elseif uses == SKILLUSES_RAGE then
						rage = usesnum
					elseif uses == SKILLUSES_FOCUS then
						focus = usesnum
					elseif uses == SKILLUSES_ENERGY then
						energy = usesnum
					elseif uses == SKILLUSES_ITEM then
						consumable = "item"
						consumableNumber = usesnum
					elseif uses == SKILLUSES_PROJECTILE then
						consumable = "projectile"
						consumableNumber = usesnum
					elseif uses == SKILLUSES_ARROW then
						consumable = "arrow"
						consumableNumber = usesnum
					elseif uses == SKILLUSES_PSI then
						psi = usesnum
					end
				end

				tabData[name] = {
					Address = address,
					BaseItemAddress = baseAddress,
					Id = id,
					aslevel = aslevel,
					Mana = mana,
					Rage = rage,
					Focus = focus,
					Energy = energy,
					Consumable = consumable,
					ConsumableNumber = consumablenumber,
					Psi = psi,
				}
			end
		end
	end

	-- Next go through the profile skills and see which are available
	for _, skill in pairs(settings.profile.skills) do
		-- Check Id
		if skill.Id == 0 or skill.Id == nil then
			if skill.hotkey == "MACRO" or skill.hotkey == "" or skill.hotkey == nil then
				-- Skill unusable without id or hotkey
				skill.Available = false
			else
				-- Might be user custom macro. Alow it.
				skill.Available = true
				-- No other values to set
			end
		else
			local realName = GetIdName(skill.Id)
			-- Do we currently have this skill?
			if tabData[realName] ~= nil then
				-- update profile values
				skill.Address = tabData[realName].Address
				skill.BaseItemAddress = tabData[realName].BaseItemAddress
				skill.Id = tabData[realName].Id
				skill.aslevel = tabData[realName].aslevel
				if tabData[realName].TPToLevel then skill.TPToLevel = tabData[realName].TPToLevel end
				if tabData[realName].Level then skill.Level = tabData[realName].Level end
				if tabData[realName].skilltab then skill.skilltab = tabData[realName].skilltab end
				if tabData[realName].skillnum then skill.skillnum = tabData[realName].skillnum end
				if tabData[realName].Mana then skill.Mana = tabData[realName].Mana end
				if tabData[realName].Rage then skill.Rage = tabData[realName].Rage end
				if tabData[realName].Focus then skill.Focus = tabData[realName].Focus end
				if tabData[realName].Energy then skill.Energy = tabData[realName].Energy end
				if tabData[realName].Consumable then skill.Consumable = tabData[realName].Consumable end
				if tabData[realName].ConsumableNumber then skill.ConsumableNumber = tabData[realName].ConsumableNumber end
				if tabData[realName].Psi then skill.Psi = tabData[realName].Psi end

				-- update database values(some functions access the database values)
				database.skills[skill.Name].Id = tabData[realName].Id
				database.skills[skill.Name].aslevel = tabData[realName].aslevel
				if tabData[realName].Level then database.skills[skill.Name].Level = tabData[realName].Level end
				if tabData[realName].skilltab then database.skills[skill.Name].skilltab = tabData[realName].skilltab end
				if tabData[realName].skillnum then database.skills[skill.Name].skillnum = tabData[realName].skillnum end

				-- Check if available
				if skill.skilltab == 3 then
					if skill.aslevel > player.Level2  then
						skill.Available = false
					else
						skill.Available = true
					end
				else
					if skill.aslevel > player.Level  then
						skill.Available = false
					else
						skill.Available = true
					end
				end
			else
				skill.Available = false
			end
		end
	end
end
