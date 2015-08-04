CAbstractDatabase = class(CBaseObject,
	function (self, copyfrom)
		self.Skills = {}
		self.Nodes = {}
		self.Utf8_ascii = {}
		self.Consumables = {}
		self.Giftbags = {}
		
		if( type(copyfrom) == "table" ) then
			self.Name = copyfrom.Name;
			self.Id = copyfrom.Id;
			self.Type = copyfrom.Type;
		end
	end
	
);


function CAbstractDatabase:load()

	local dirs = seekDir("database/skills.xml")
	
	if( dirs )then
		self:loadSkills(dirs);
	else
		print("Warning didn't found skills.xml")
	end
	
	local dirn = seekDir("database/nodes.xml")
	
	if( dirn )then
		self:loadNodes(dirn);
	else
		print("Warning didn't found nodes.xml")
	end
	
	local diru = seekDir("database/utf8_ascii.xml")
	
	if( diru )then
		self:loadUtf8(diru);
	else
		print("Warning didn't found utf8_ascii.xml")
	end
	
	local dirc = seekDir("database/consumables.xml")
	
	if( dirc )then
		self:loadConsumables(dirc);
	else
		print("Warning didn't found consumables.xml")
	end
	
	local dirg = seekDir("database/giftbags.xml")
	
	if( dirg )then
		self:loadGiftbags(dirg);
	else
		print("Warning didn't found giftbags.xml")
	end
end

function CAbstractDatabase:loadSkills(dir)

	--local root =  parser:open(getExecutionPath() .. "/database/skills.xml");
	local root =  parser:open(dir);
	local elements = root:getElements();


	for i,v in pairs(elements) do
		local tmp = CSkill();
		local name, id, targetmaxhpper, targetmaxhp, maxhpper, maxmanaper, energytype, energyvalue
		local range, minrange, casttime, cooldown, type, target, autouse;
		local toggleable, minmanaper, inbattle, priority, level, aslevel, skilltab, skillnum;
		local buffname, reqbuffcount, reqbufftarget, reqbuffname, nobuffcount, nobufftarget, nobuffname;
		local enemydodge, enemycritical, playerblock, playerdodge, playerparalyzed, playerdead, playeritem, playerstate 
		local action 
		
		name = v:getAttribute("name");
		id = v:getAttribute("id");
		range = v:getAttribute("range");
		minrange = v:getAttribute("minrange");
		casttime = v:getAttribute("casttime");
		cooldown = v:getAttribute("cooldown");
		type = v:getAttribute("type");
		target = v:getAttribute("target");
		autouse = v:getAttribute("autouse");
		toggleable = v:getAttribute("toggleable");
		maxhpper = v:getAttribute("maxhpper");
		
		-- What if we need multiply resources ? 
		energytype = v:getAttribute("energytype") or ""
		energyvalue =  v:getAttribute("energyvalue") or ""
		
		--We never used them but also they won't work with energy?!
		maxenergyper = v:getAttribute("maxenergyper");
		minmenergyper = v:getAttribute("minenergyper");
		
		targetmaxhpper = v:getAttribute("targetmaxhpper");
		targetmaxhp = v:getAttribute("targetmaxhp");
		inbattle = v:getAttribute("inbattle");
		priority = v:getAttribute("priority");
		
		--some player states + general buffs and debuffs goes extra
		enemydodge = v:getAttribute("enemydodge")
		enemycritical = v:getAttribute("enemycritical")
		playerblock = v:getAttribute("playerblock")
		playerdodge = v:getAttribute("playerdodge")
		playerparalyzed	= v:getAttribute("playerparalyzed")
		playerdead = v:getAttribute("playerdead")
		playeritem =  v:getAttribute("playeritem") --item or itemtype
		playerstate =  v:getAttribute("playerstate") or "" -- everything which don't fit in with the rest
		
		buffname = tostring(v:getAttribute("buffname") or "");
		reqbuffcount = tonumber(v:getAttribute("reqbuffcount") or 0);
		reqbufftarget = string.lower(tostring(v:getAttribute("reqbufftarget") or "player"));
		reqbuffname = tostring(v:getAttribute("reqbuffname") or "");
		nobuffcount = tonumber(v:getAttribute("nobuffcount") or 0);
		nobufftarget = string.lower(tostring(v:getAttribute("nobufftarget") or "player"));
		nobuffname = tostring(v:getAttribute("nobuffname") or "");

		aoecenter = string.lower(v:getAttribute("aoecenter") or "");
		aoerange = v:getAttribute("aoerange") or ""
		clicktocast = v:getAttribute("clicktocast")
		globalcooldown = v:getAttribute("globalcooldown")
		addweaponrange = v:getAttribute("addweaponrange")
		
		-- execute code on pre when use sklill 
		 action = v:getValue();
		-- Automatically assign priority (if not given) based on type
		if( not priority ) then
			if( type == "damage" ) then
				priority = 70;
			elseif( type == "hot" ) then
				priority = 110;
			elseif( type == "heal" ) then
				priority = 100;
			elseif( type == "buff" ) then
				priority = 90;
			elseif( type == "summon" ) then
				priority = 95;
			elseif( type == "dot" ) then
				priority = 80;
			end;
		end

		-- Re-assign type to an actual defined type (improves speed; reduces slow string compares)
		if( type == "damage" ) then
			type = STYPE_DAMAGE;
		elseif( type == "hot" ) then
			type = STYPE_HOT;
		elseif( type == "heal" ) then
			type = STYPE_HEAL;
		elseif( type == "buff" ) then
			type = STYPE_BUFF;
		elseif( type == "summon" ) then
			type = STYPE_SUMMON;
		elseif( type == "dot" ) then
			type = STYPE_DOT;
		end;

		if clicktocast == true and aoecenter == "" then
			aoecenter = SAOE_TARGET
		end

		if aoecenter == "player" then
			aoecenter = SAOE_PLAYER
		elseif aoecenter == "target" or aoecenter == SAOE_TARGET then
			aoecenter = SAOE_TARGET
			if aoerange == "" then
				if clicktocast == true then
					aoerange = 65
				else
					aoerange = 50
				end
			end
		end

		if addweaponrange ~= true then
			addweaponrange = nil
		end


		if( target == "enemy" ) then target = STARGET_ENEMY; end;
		if( target == "self" ) then target = STARGET_SELF; end;
		if( target == "friendly" ) then target = STARGET_FRIENDLY; end;
		if( target == "party" ) then target = STARGET_PARTY; end;

		if(name) then tmp.Name = name; end;
		if(id) then tmp.Id = id; end;
		if(energytype) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(energytype, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.EnergyType = t;
		end;
		
		if(energyvalue) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(energyvalue, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.EnergyValue = tonumber( t );
		end;
		
		if(range) then tmp.Range = range; end;
		if(minrange) then tmp.MinRange = minrange; end;
		if(casttime) then tmp.CastTime = casttime; end;
		if(cooldown) then tmp.Cooldown = cooldown; end;
		if(type) then tmp.Type = type; end;
		if(target) then tmp.Target = target; end;
		if(autouse~=nil) then tmp.AutoUse = autouse; end;
		if(toggleable) then tmp.Toggleable = toggleable; end;
		if(targetmaxhp) then tmp.TargetMaxHp = targetmaxhp; end;
		if(targetmaxhpper) then tmp.TargetMaxHpPer = targetmaxhpper; end;
		if(maxhpper) then tmp.MaxHpPer = maxhpper; end;
		if(maxenergyper) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(maxenergyper, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.MaxEnergyPer = tonumber(t);
		end;
		if(minenergyper) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(minenergyper, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.MinEnergyPer = tonumber(t);
		
		tmp.MinEnergyPer = minenergyper;
		end;
		if(inbattle ~= nil) then tmp.InBattle = inbattle; end;
		if(priority) then tmp.priority = priority; end;
		if(level) then tmp.Level = level; end;
		if(aslevel) then tmp.aslevel = aslevel; end;
		if(skilltab) then tmp.skilltab = skilltab; end;
		if(skillnum) then tmp.skillnum = skillnum; end;

		if(buffname ~= "") then tmp.BuffName = buffname; end;
		if(reqbuffcount ~= "" ) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(reqbuffcount, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.ReqBuffCount = tonumber(t);
		end;
		if(reqbufftarget ~= "") then tmp.ReqBuffTarget = reqbufftarget; end;
		if(reqbuffname and reqbuffname ~= "") then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(reqbuffname, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.ReqBuffName = t 
		end;
		if(nobuffcoun and nobuffcount ~="" ) then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(nobuffcount, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.NoBuffCount = t;
		end;
		if(nobufftarget ~= "") then tmp.NoBuffTarget = nobufftarget; end;
		if(nobuffname and nobuffname ~= "") then 
			local t = {}
			local i = 1;
				
			for token in string.gmatch(nobuffname, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			
			tmp.NoBuffName = t;
		end;
		if(aoecenter ~= "") then tmp.AOECenter = aoecenter; end;
		if(aoerange ~= "") then tmp.AOERange = aoerange; end;
		if(clicktocast ~= "") then tmp.ClickToCast = clicktocast; end;
		if(globalcooldown ~= nil) then tmp.GlobalCooldown = globalcooldown; end;
		if(addweaponrange ~= nil) then tmp.AddWeaponRange = addweaponrange; end;

		if(enemydodge) then tmp.EnemyDodge = true; end;
		if(enemycritical) then tmp.EnemyCritical = true; end;
		if(playerdodge) then tmp.PlayerDodge = true; end;
		if(playerblock) then tmp.PlayerBlock = true; end;
		if(playerparalyzed~= nil) then tmp.PlayerParalyzed = playerparalyzed end;
		if(playerdead~= nil) then tmp.Playerdead = playerdead end;
		if(playeritem and playeritem ~="") then
			local t = {}
			local i = 1;
				
			for token in string.gmatch(playeritem, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.PlayerItem = t
		end;
		if(playerstate and playerstate ~="") then
			local t = {}
			local i = 1;
				
			for token in string.gmatch(playerstate, "[^,]+") do
				
				t[i] = token;
				i= i + 1;
			end
			
			tmp.PlayerState = t;
		end;
		
		if(action) then tmp.Action = action end;
		
		self.Skills[name] = tmp;
	end

end

function CAbstractDatabase:loadNodes(dir)
	-- import nodes/ressouces
	--root =  parser:open(getExecutionPath() .. "/database/nodes.xml");
	root =  parser:open(dir);
	elements = root:getElements();

	for i,v in pairs(elements) do
		local name, id, type, level;
		local tmp = CNode();

		name = v:getAttribute("name");
		id = v:getAttribute("id");
		type = v:getAttribute("type");
		level = v:getAttribute("level");

		if( type == "WOOD" ) then
			type = NTYPE_WOOD;
		elseif( type == "ORE" ) then
			type = NTYPE_ORE;
		elseif( type == "HERB" ) then
			type = NTYPE_HERB;
		end;

		tmp.Name = name;
		tmp.Id = id;
		tmp.Type = type;
		tmp.Level = level;

		self.Nodes[id] = tmp;
	end

end
function CAbstractDatabase:loadUtf8(dir)
	-- UTF-8 -> ASCII translation
	--root =  parser:open(getExecutionPath() .. "/database/utf8_ascii.xml");
	root =  parser:open(dir);
	elements = root:getElements();

	for i,v in pairs(elements) do
		local utf8_1, utf8_2, ascii, dos_replace;
		local tmp = {};

		utf8_1 = v:getAttribute("utf8_1");
		utf8_2 = v:getAttribute("utf8_2");
		ascii = v:getAttribute("ascii");
		dos_replace = v:getAttribute("dos_replace");

--		tmp.Name = name;
		tmp.utf8_1 = utf8_1;
		tmp.utf8_2 = utf8_2;
		tmp.ascii = ascii;
		tmp.dos_replace = dos_replace;

		local key = utf8_1*1000 + utf8_2;
		self.Utf8_ascii[key] = tmp;
	end
end
function CAbstractDatabase:loadConsumables(dir)
	-- import consumables (potions, arrows, stones, ...)
	--root =  parser:open(getExecutionPath() .. "/database/consumables.xml");
	root =  parser:open(dir);
	elements = root:getElements();

	for i,v in pairs(elements) do
	    local type, name, level, potency, id, energy
		local tmp = {};

		type = v:getAttribute("type");
		name = v:getAttribute("name");
		level = v:getAttribute("level");
		energy = v:getAttribute("energy");
		potency = v:getAttribute("potency");
		id = v:getAttribute("id");

		if (type) then tmp.Type = type; end;
		if (name) then tmp.Name = name; end;
		if (level) then tmp.Level = level; end;
		if (energy)then tmp.Energy = energy; end;
		if (potency) then
			tmp.Potency = potency;
		else
			tmp.Potency = 0;
		end;
		if (id) then tmp.Id = id; end;

		self.Consumables[id] = tmp;
	end
end

function CAbstractDatabase:loadGiftbags(dir)
	-- import giftbag contents
	--root =  parser:open(getExecutionPath() .. "/database/giftbags.xml");
	root =  parser:open(dir);
	elements = root:getElements();

	for i,v in pairs(elements) do
	    local itemid, type, armor, level, name;
		local tmp = {};

		itemid = v:getAttribute("itemid");
		type   = v:getAttribute("type");
		armor  = v:getAttribute("armor");
		level  = v:getAttribute("level");
		name   = v:getAttribute("name");

		if (itemid) then tmp.itemid = itemid; end;
		if (type)   then tmp.type   = type;   end;
		if (armor)  then tmp.armor  = armor;  end;
		if (level)  then tmp.level  = level;  end;
		if (name)   then tmp.name   = name;   end;

		self.Giftbags[i] = tmp;
	end

end
function CAbstractDatabase:getSkills()
	return self.Skills;
end
function CAbstractDatabase:getSkill(name)
	return self.Skills[name];
end
function CAbstractDatabase:getNodes()
	return self.Nodes;
end
function CAbstractDatabase:getNode(name)
	return self.Nodes[name];
end
function CAbstractDatabase:getUtf8s()
	return self.Utf8_ascii;
end
function CAbstractDatabase:getUtf8(name)
	return self.Utf8_ascii[name];
end
function CAbstractDatabase:getConsumables()
	return self.Consumables;
end
function CAbstractDatabase:getConsumable(name)
	return self.Consumables[name];
end
function CAbstractDatabase:getGiftbags()
	return self.Giftbags;
end
function CAbstractDatabase:getGiftbag(name)
	return self.Giftbags[name];
end
	