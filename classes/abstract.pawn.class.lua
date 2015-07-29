
dyinclude("meta-settings/pawns.settings.lua");
include("objectqueue.class.lua");

-- used in function.lua for openGiftbag()
armorMap = pawns.settings["armor_map"];

local classEnergyMap = pawns.settings["classEnergyMap"];

CAbstractPawn = class(CObject,
	function (self, ptr)
		self.Address = ptr;
		self.Name = "<UNKNOWN>";
		self.Id = -1;
		self.GUID  = 0;
		self.Type = PT_NONE;
		self.Classes = pawns.funcs["init_all_classes"]();
		self.Guild = "<UNKNOWN>";
		self.Levels =  pawns.funcs["init_all_levels"]();
		self.HP = 1000;
		self.LastHP = 0;
		self.MaxHP = 1000;
		self.ActivEnergys = pawns.funcs["init_all_activ_energys"]()
		self.Energys = pawns.funcs["init_all_energys"]()
		self.Race = pawns.settings["races_default"];
		self.X = 0.0;
		self.Y = 0.0;
		--make it optional take a look at update
		self.Z = 0.0;
		--end
		self.TargetPtr = 0;
		self.Direction = 0.0;
		self.Attackable = false;
		self.Alive = true;
		self.Mounted = false;
		self.Lootable = false;
		self.Aggressive = false;
		self.Harvesting = false; -- Whether or not we are currently harvesting
		self.Casting = false;
		self.TargetIcon = true
		self.InParty = false
		self.Swimming = false
		self.Speed = 50
		self.IsPet = nil
		self.Buffs = {};

		--if( self.Address ~= 0 and self.Address ~= nil ) then self:update(); end
	end
);


function CAbstractPawn.new(address)
	local np = CAbstractPawn()
	np.Address = address
	return np
end

function CAbstractPawn:getClass(index)

	if index == nil then
		index = 1;
	end
	return self.Classes[index];
end
function CAbstractPawn:getLevel(index)

	if index == nil then
		index = 1;
	end
	return self.Levels[index];
end
function CAbstractPawn:getEnergy(name)
	return self.Energys[name];
end
function CAbstractPawn:getBuff(index)
	return self.Buffs[index];
end
function CAbstractPawn:getDirection()
	return self.Direction;
end
function CAbstractPawn:getAngleDifference(angle2)
	if type(angle2) == "table" then
		return self:getAngleDifference(angle2:getDirection());
	end
	if( math.abs(angle2 - self:getDirection()) > math.pi ) then
		return (math.pi * 2) - math.abs(angle2 - self:getDirection());
	else
		return math.abs(angle2 - self:getDirection());
	end
end

function CAbstractPawn:exists()
	self:updateId()

	return self.Id ~= 0
end

function CAbstractPawn:updateRace()
	self.Race = InputOutput:PawnRace(self) or self.Race;
end
function CAbstractPawn:updateTargetIcon()

	local attackableFlag = InputOutput:PawnAttackable(self)
	
	local eval_target_icon = pawns.funcs["pawn_eval_target_icon"];
	if attackableFlag then
	
		if eval_target_icon(attackableFlag)then
			self.TargetIcon = true
		else
			self.TargetIcon = false
		end
		
	end
end

function CAbstractPawn:updateGUID()
	if not self:hasAddress() then
		self.GUID = 0
		return
	end
	self.GUID = InputOutput:PawnGUID( self ) or self.GUID;
end



function CAbstractPawn:updateAlive()
	if not self:hasAddress() then
		self.Alive = false
		return
	end
	local eval_alive = pawns.funcs["pawn_eval_alive"];
	-- Check Alive flag
	local alive = InputOutput:PawnIsAlive(self)
	self.Alive = eval_alive(alive);

	-- If 'alive' then also check if fading (only for mobs).
	if self.Alive then
		self:updateType()
		if self.Type == PT_MONSTER or self.Type == PT_NODE then
			self.Alive = InputOutput:PawnIsFading(self) == 0;
		end
	end
end

function CAbstractPawn:updateHP()
	if not self:hasAddress() then
		self.HP = 0
		return
	end

	self.HP = InputOutput:PawnHP(self) or self.HP;

	self.MaxHP = InputOutput:PawnMaxHP(self) or self.MaxHP;
end

function CAbstractPawn:updateLastHP()
	if not self:hasAddress() then
		self.LastHP = 0
		return
	end

	local tmpLastHP = InputOutput:PawnLastHP(self)
	if tmpLastHP then
		self.LastHP = tmpLastHP
		if player and self.LastHP ~= player.PawnLastHP then
			player.PawnLastHP = self.LastHP
			player.LastHitTime = getGameTime()
		end
	end
end

function CAbstractPawn:updateClass()
	if not self:hasAddress() then
		self.Classes = pawns.funcs["pawn_init_all_classes"]();
		return
	end
	
	for i = 1, pawns.settings["max_number_classes_activ"] do
		self.Classes[i] = InputOutput:PawnClass(i, self);
	end
end

function CAbstractPawn:updateMP()
	if not self:hasAddress() then
		self.ActivEnergys = pawns.funcs["init_zero_activ_energy"](self.ActivEnergys);
		return
	end
	local max_energys_peer_char = pawns.settings["max_number_energys_activ"];
	
	local k = 0
	for i = 1,  max_energys_peer_char * 2 , 1 do 
		-- repeat reading in the orignally
		self.ActivEnergys[i+k] = InputOutput:PawnEnergy(i, self);
		self.ActivEnergys[i+1+k] = InputOutput:PawnMaxEnergy(i, self);
		k = k + 1;
	end
	
	--- Prevent division by zero for entities that have no mana
	for i = 1,  max_energys_peer_char *2 do 
		if self.ActivEnergys[i] == 0 then
			self.ActivEnergys[i] = 1;
		end
	end
	if self.Classes[1] == pawns.settings["class_types"]["CLASS_NONE"] then
		self:updateClass()
	end

	-- Set the correct mana/rage/whatever
	local energyStorage = {};
	
	for i = 1,  max_energys_peer_char do 
		energyStorage[i] = classEnergyMap[self.Classes[i]];
	end
	
	-- this a bit of geometric maths I hope it works
	--make the lower half
	for i = 1,  max_energys_peer_char/2 do 
		-- make the upper half
		for j = max_energys_peer_char/2,  max_energys_peer_char do 
			if i ~= j then
				if(energyStorage[i] == energyStorage[j]then
					energyStorage[j] = "none";
				end
			end
		end
	end
	-- this will result in mana, Maxmana,rage, Maxrage
	for i = 1,  max_energys_peer_char * 2 do 
		if(i%2 == 0)then
			self.Energys["Max"..energyStorage[i-1]] = self.ActivEnergys[i];
		else
			self.Energys[energyStorage[i]] = self.ActivEnergys[i];
		end
	end
	
end

function CAbstractPawn:updateBuffs()
	if not self:hasAddress() then
		self.buffs = {};
		return
	end

	local proc = getProc()
	local BuffSize = pawns.settings["size_buff"];
	local buffStart, buffEnd = InputOutput:PawnBuffStartEnde(self);
	

	self.Buffs = {} -- clear old values
	if buffStart == nil or buffEnd == nil or buffStart == 0 or buffEnd == 0 then return end
	if (buffEnd - buffStart)/ BuffSize > pawns.settings["max_number_buff"] then -- Something wrong, too many buffs
		return
	end

	for i = buffStart, buffEnd - pawns.settings["shorten_number_of_buffs"], BuffSize do
		local tmp = {}
		--yrest(1)
		tmp.Id = InputOutput:PawnBuffID(i, self);
		local name = pawns.funcs["pawn_buff_resolution"](tmp.Id);

		if name ~= nil then
			tmp.Name, tmp.Count = parseBuffName(name)
			tmp.TimeLeft = InputOutput:PawnBuffTimeLeft(i, self);
			tmp.Level = InputOutput:PawnBuffLevel(i, self);

			table.insert(self.Buffs,tmp)
		end
	end
end

function CAbstractPawn:updateLootable()
	if not self:hasAddress() then
		self.Lootable = false;
		return
	end

	local tmp = InputOutput:PawnLootable(Address)
	if( tmp ) then
		self.Lootable = pawns.funcs["pawn_eval_lootable"](tmp);
	else
		self.Lootable = false;
	end
end

function CAbstractPawn:updateHarvesting()
	if not self:hasAddress() then
		self.Harvesting = false;
		return
	end

	self.Harvesting = InputOutput:PawnHarvesting(self)
end

function CAbstractPawn:updateCasting()
	if not self:hasAddress() then
		self.Casting = false;
		return
	end

	self.Casting = InputOutput:PawnCasting(self)
end

function CAbstractPawn:updateLevel()
	if not self:hasAddress() then
		self.Level = 1;
		return
	end
	for i = 1,#self.Levels do
		self.Levels[i] = InputOutput:PawnLevel(i, self);
	end
end

function CAbstractPawn:updateTargetPtr()
	if not self:hasAddress() then
		self.TargetPtr = 0;
		return
	end


	local tmpTargetPtr = InputOutput:PawnTargetPtr(self);

	if tmpTargetPtr ~= 0 then
		self.TargetPtr = tmpTargetPtr
		return
	end

	if self.TargetPtr ~= 0 then
		-- Check if still valid
		local addressId = InputOutput:PawnId(self);

		if addressId == 0 or addressId > 999999 then -- The target no longer exists
			self.TargetPtr = 0
		end
	end

	return 0
end


function CAbstractPawn:updateDirection()
	if not self:hasAddress() then
		return
	end

	local Vec1 = InputOutput:PawnDirection("X", self );
	local Vec2 = InputOutput:PawnDirection("Z", self );
	local Vec3 = InputOutput:PawnDirection("Y", self );

	if( Vec1 == nil ) then Vec1 = 0.0; end;
	if( Vec2 == nil ) then Vec2 = 0.0; end;
	if( Vec3 == nil ) then Vec3 = 0.0; end;

	self.Direction = math.atan2(Vec2, Vec1);
	if(Vec3)then
		self.DirectionY = math.atan2(Vec3, (Vec1^2 + Vec2^2)^.5 );
	end
end

function CAbstractPawn:updateMounted()
	if not self:hasAddress() then
		self.Mounted = false;
		return
	end

	local attackableFlag =  InputOutput:PawnAttackable(self)
	if attackableFlag then
		self.Mounted = pawns.funcs["pawn_eval_mounted"](attackableFlag);
	end
end

function CAbstractPawn:updateInParty()
	if not self:hasAddress() then
		self.InParty = false;
		return
	end

	local attackableFlag = InputOutput:PawnAttackable(self)
	--=== InParty indicator ===--
	if attackableFlag and pawns.funcs["pawn_eval_inparty"](attackableFlag) then
		self.InParty = true
	else
		self.InParty = false
	end
end

function CAbstractPawn:updateAttackable()
	if not self:exists() then
		return
	end

	self:updateType()
	if( self.Type == PT_MONSTER or pawns.settings["attack_anything"]) then
		local attackableFlag = InputOutput:PawnAttackable(self)
		if attackableFlag then
			pawns.funcs["pawn_eval_aggressive_and_attackable"](attackableFlag, self);
		end
	else
		self.Attackable = false;
	end
end

function CAbstractPawn:updateSwimming()
	if not self:hasAddress() then
		return
	end

	local tmp = InputOutput:PawnSwimming( self )
	self.Swimming = pawns.funcs["pawn_eval_swim"](tmp);
end

function CAbstractPawn:updateIsPet()
	if not self:hasAddress() then
		self.IsPet = nil
		return
	end

	if self.IsPet == nil then -- not updated yet
		self.IsPet = InputOutput:PawnIsPet( self )
		if self.IsPet == 0 then self.IsPet = false end
	end
end

function CAbstractPawn:updateSpeed()
	self.Speed = InputOutput:PawnSpeed( self )
end

function CAbstractPawn:haveTarget()
	-- Update TargetPtr
	self:updateTargetPtr()

	if( self.TargetPtr == 0 ) then
		return false;
	end;

	local tmp = CAbstractPawn.new(self.TargetPtr)

	if not tmp:isAlive() then
		return false
	end

	return true
end

function CAbstractPawn:getTarget()
	self:updateTargetPtr();
	if( self.TargetPtr ) then
		return CAbstractPawn(self.TargetPtr);
	else
		return nil;
	end
end

function CAbstractPawn:isAlive()
	-- Check if still valid target
	if not self:exists() then
		return false
	end

	-- Dead
	self:updateHP()
	if( self.HP < 1 ) then
		return false;
	end

	-- Also dead (and has loot)
	self:updateLootable()
	if( self.Lootable ) then
		return false;
	end

	self:updateAlive()
	if( not self.Alive ) then
		return false;
	end

	return true
end

function CAbstractPawn:distanceToTarget()
	self:updateTargetPtr()
	if( self.TargetPtr == 0 ) then return 0; end;

	local target = CAbstractPawn.new(self.TargetPtr);
	target:updateXYZ()
	self:updateXYZ()
	local tx,ty,tz = target.X, target.Y, target.Z;
	local px,py,pz = self.X, self.Y, self.Z;

	return math.sqrt( (tx-px)*(tx-px) + (ty-py)*(ty-py) + (tz-pz)*(tz-pz) );
end

function CAbstractPawn:hasBuff(buffname, count)
	local buff = self:getBuff(buffname, count)

	if buff then
		return true, buff.Count -- count returned for backward compatibility
	else
		return false, 0
	end
end

function CAbstractPawn:hasDebuff(debuff, count)
	return self:hasBuff(debuff, count)
end

function CAbstractPawn:getBuff(buffnamesorids, count)
	self:updateBuffs()

	--it's a number so we do it simple
	if( type(tonumber(buffnamesorids))  == "number")then
		-- for each buff the pawn has
		for i, buff in pairs(self.Buffs) do
			-- compare against each 'buffname'
			if( tonumber(buffnamesorids) == buff.Id )then
				--print("we do it")
				return buff
			end
		end
	end
	for i, buff in pairs(self.Buffs) do
		-- compare against each 'buffname'
		for buffname in string.gmatch(buffnamesorids,"[^,]+") do
			if type(tonumber(buffname)) == "number" then
				-- Get name from id
				buffname = GetIdName(tonumber(buffname))
				-- Take of end numbers
				buffname = parseBuffName(buffname)
			end
			if buffname == buff.Name and ( count == nil or buff.Count >= count ) then
				return buff
			end
		end
	end

	return false
end

function parseBuffName(buffname)
	if buffname == nil then return end

	local name, count

	-- First try and find '(3)' type count in name
	local tmpCount = string.match(buffname,"%((%d+)%)$")
	if tmpCount then
		count = tonumber(tmpCount)
		name = string.match(buffname,"(.*)%s%(%d+%)$")
		return name, count
	end

	-- Then try and find ' 3' type count in name
	local tmpCount = string.match(buffname,"%s(%d+)$")
	if tmpCount then
		count = tonumber(tmpCount)
		name = string.match(buffname,"(.*)%s%d+$")
		return name, count
	end

	-- Next try and find roman numeral number
	tmpCount = string.match(buffname,"%s([IVX]+)$")
	if tmpCount then
		-- Convert roman number to number
		if tmpCount == "I" then count = 1
		elseif tmpCount == "II" then count = 2
		elseif tmpCount == "III" then count = 3
		elseif tmpCount == "IV" then count = 4
		elseif tmpCount == "V" then count = 5
		elseif tmpCount == "VI" then count = 6
		elseif tmpCount == "VII" then count = 7
		elseif tmpCount == "VIII" then count = 8
		elseif tmpCount == "IX" then count = 9
		elseif tmpCount == "X" then count = 10
		end
		name = string.match(buffname,"(.*)%s[IVX]+$")
		return name, count
	end

	-- Buff not stackable
	return buffname, 1
end

function CAbstractPawn:GetPartyIcon()
	self:updateGUID()
	local listStart = InputOutput:PawnIconBase(selfe)
	for i = 0, pawns.settings["max_party_icons"] do
		local guid = InputOutput:PawnIconRead( listStart + i * pawns.settings["party_icons_size"])
		if guid == self.GUID then
			return i + 1
		end
	end
end

function CAbstractPawn:countMobs(inrange, onlyaggro, idorname)
	self:updateXYZ()
	local count = 0

	local objectQueue = CObjectQueue();
	objectQueue:update();
	while(objectQueue:peek()) do
		local obj =  objectQueue:poll(PT_MONSTER);
		if(inrange == nil or inrange >= distance(self.X,self.Z,self.Y,obj.X,obj.Z,obj.Y) ) and
		  (idorname == nil or idorname == obj.Name or idorname == obj.Id) then
			local pawn = CAbstractPawn.new(obj.Address)
			pawn:updateAlive()
			pawn:updateHP()
			pawn:updateAttackable()
			pawn:updateLevel()
			if pawn.Alive and pawn.HP >=1 and pawn.Attackable and pawn.Level > 1 then
				if onlyaggro == true then
					pawn:updateTargetPtr()
					if pawn.TargetPtr == player.Address then
						count = count + 1
					end
				else
					count = count + 1
				end
			end
		end
	end

	return count
end

function CAbstractPawn:findBestClickPoint(aoerange, skillrange, onlyaggro)
	-- Finds best place to click to get most mobs including this pawn.
	self:updateXYZ()

	player:updateXYZ()
	local MobList = {}
	local EPList = {}

	local function CountMobsInRangeOfCoords(x,z)
		local c = 0
		local list = {}
		for k,mob in ipairs(MobList) do
			if distance(x,z,mob.X,mob.Z) <= aoerange then
				table.insert(list,k)
				c=c+1
			end
		end
		return c, list
	end

	local function GetEquidistantPoints(p1, p2, dist)
		-- Returns the 2 points that are both 'dist' away from both p1 and p2
		local xvec = p2.X - p1.X
		local zvec = p2.Z - p1.Z
		local ratio = math.sqrt(dist*dist/(xvec*xvec +zvec*zvec) - 0.25)
		-- transpose
		local newxvec = zvec * ratio
		local newzvec = xvec * ratio

		local ep1 = {X = (p1.X + p2.X)/2 + newxvec, Z = (p1.Z + p2.Z)/2 - newzvec}
		local ep2 = {X = (p1.X + p2.X)/2 - newxvec, Z = (p1.Z + p2.Z)/2 + newzvec}

		return ep1, ep2
	end

	-- The value this function needs to beat or match (if aoe center is this pawn)
	local countmobs = self:countMobs(aoerange, onlyaggro)

	-- Check if user wants to bypass this function
	if settings.profile.options.FORCE_BETTER_AOE_TARGETING == false then
		return countmobs, self.X, self.Z
	end

	-- First get list of mobs within (2 x aoerange) of this pawn and (skillrange + aoerange) from player.
	local objectQueue = CObjectQueue();
	objectQueue:update();
	while(objectQueue:peek()) do
		local obj =  objectQueue:poll(PT_MONSTER);
		if (settings.profile.options.FORCE_BETTER_AOE_TARGETING == true or 0.5 > math.abs(obj.Y - self.Y)) and -- only count mobs on flat floor, results would be unpredictable on hilly surfaces when clicking.
		  aoerange*2 >= distance(self.X,self.Z,self.Y,obj.X,obj.Z,obj.Y) and (skillrange + aoerange >= distance(player.X, player.Z, obj.X, obj.Z)) then
			local pawn = CAbstractPawn.new(obj.Address);
			pawn:updateAlive()
			pawn:updateHP()
			pawn:updateAttackable()
			pawn:updateLevel()
			pawn:updateXYZ() -- For the rest of the function
			if pawn.Alive and pawn.HP >=1 and pawn.Attackable and pawn.Level > 1 then
				if onlyaggro == true then
					pawn:updateTargetPtr()
					if pawn.TargetPtr == player.Address then
						table.insert(MobList,pawn)
					end
				else
					table.insert(MobList,pawn)
				end
			end
		end
	end

	-- Deal with easy solutions
	if countmobs > #MobList or #MobList < 2 then
		return countmobs, self.X, self.Z
	elseif #MobList == 2 then
		local averageX = (MobList[1].X + MobList[2].X)/2
		local averageZ = (MobList[1].Z + MobList[2].Z)/2
		return 2, averageX, averageZ
	end

	-- Get list of best equidistant points(EPs) and add list of mobs in range for each point
	local bestscore = 0
	for p1 = 1, #MobList-1 do
		local mob1 = MobList[p1]
		for p2 = p1+1, #MobList do
			local mob2 = MobList[p2]
			local ep1, ep2 = GetEquidistantPoints(mob1, mob2, aoerange - 3) -- '-1' buffer
			-- Check ep1 and add
			if aoerange >= distance(ep1, self) then -- EP doesn't miss primary target(self)
				local tmpcount, tmplist = CountMobsInRangeOfCoords(ep1.X, ep1.Z)
				if tmpcount > bestscore then
					bestscore = tmpcount
					EPList = {} -- Reset for higher scoring EPs
				end
				if tmpcount == bestscore then
					ep1.Mobs = tmplist
					table.insert(EPList,ep1)
				end
			end
			-- Check ep2 and add
			if aoerange > distance(ep2,self) then -- EP doesn't miss primary target(self)
				local tmpcount, tmplist = CountMobsInRangeOfCoords(ep2.X, ep2.Z)
				if tmpcount > bestscore then
					bestscore = tmpcount
					EPList = {} -- Reset for higher scoring EPs
				end
				if tmpcount == bestscore then
					ep2.Mobs = tmplist
					table.insert(EPList,ep2)
				end
			end
		end
	end

	-- Is best score good enough to beat self:countMobs?
	if countmobs > bestscore then
		return countmobs, self.X, self.Z
	end

	-- Sort EP mob lists for easy comparison
	for i = 1, #EPList do
		table.sort(EPList[i].Mobs)
	end

	-- Find a set of EPs with matching mob list to first
	local BestEPSet = {EPList[1]}
	for i = 2, #EPList do
		local match = true
		for k,v in ipairs(EPList[1].Mobs) do
			if v ~= EPList[i].Mobs[k] then
				match = false
				break
			end
		end
		-- Same points
		if match then
			table.insert(BestEPSet,EPList[i])
		end
	end

	-- Get average of EP points. That is our target point
	local totalx, totalz = 0, 0
	for k,v in ipairs(BestEPSet) do
		totalx = totalx + v.X
		totalz = totalz + v.Z
	end

	-- Average x,z
	local AverageX = totalx/#BestEPSet
	local AverageZ = totalz/#BestEPSet

	return bestscore, AverageX, AverageZ
end

-- returns true if this CAbstractPawn is registered as a friend
function CAbstractPawn:isFriend( aggroonly)
	-- Is self still valid
	if not self:exists() then
		return false
	end

	-- Pets are friends
	if( player.PetPtr ~= 0 and self:GetAddress() == player.PetPtr ) then
		return true;
	end

	-- Following options need 'settings'
	if( not settings ) then
		return false;
	end;

	-- Are they in party
	self:updateInParty()
	if settings.profile.options.PARTY == true and self.InParty then
		return true
	end

	-- If passed above tests and not friend and only interested in pawn that cause aggro, then return false
	if aggroonly == true then
		return false
	end

	-- Are they on the friends list
	self:updateName()
	for i,v in pairs(settings.profile.friends) do
		if( string.find( string.lower(self.Name), string.lower(v), 1, true) ) or tonumber(v) == self.Id then
			return true;
		end
	end

	return false;
end

-- returns true if this CAbstractPawn target is registered as a friend
function CAbstractPawn:targetIsFriend(aggroonly)
	-- Is self still valid
	if not self:exists() then
		return false
	end

	self:updateTargetPtr()
	if self.TargetPtr == 0 then
		return false
	end

	local target = CAbstractPawn.new(self.TargetPtr)

	return target:isFriend(aggroonly)
end

function CAbstractPawn:getRemainingCastTime()

	local casttime,castsofar = InputOutput:PawnCast(self)

	if casttime and castsofar then
		return casttime - castsofar, casttime
	else
		return 0,0
	end
end

function CAbstractPawn:isOnMobIgnoreList()
	for k, v in pairs(player.MobIgnoreList) do
		if v:GetAddress() == self:GetAddress() then
			-- Check if we can clear it
			if distance(player,player.LastPlaceMobIgnored) > 50 and
			   os.clock()-v.Time > 10 then
				table.remove(player.MobIgnoreList,k)
				return false
			else
				return true
			end
		end
	end

	return false
end

function CAbstractPawn:getLastDamage()
	pawns.funcs["pawn_eval_last_damage"](self);
end

function CAbstractPawn:getLastCriticalTime()
	pawns.funcs["pawn_eval_last_crit"](self);
end

function CAbstractPawn:getLastDodgeTime()
	pawns.funcs["pawn_eval_last_doge"](self);
end
