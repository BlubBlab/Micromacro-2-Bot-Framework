dyinclude("meta-settings/player.settings.lua");
dyinclude("extension-classes/pawn.class.lua");
dyinclude("extension-classes/movement.class.lua");



local BreakFromFight = false
local break_fight = false;	-- flag to avoid kill counts for breaked fights
local lootIgnoreList = {}
local lootIgnoreListPos = 0
local Movement = CMovement();

CPlayer = class(CPawn,
	function (self, ptr)
		CPawn.constructor(self) -- call pawn constructor manually without 'ptr' arg.
		self.Address = ptr;

		-- Experience tracking variables
		self.LastExpUpdateTime = os.time();
		self.LastExp = 0;				-- The amount of exp we had last check
		self.ExpUpdateInterval = 10;	-- Time in seconds to update exp
		self.ExpTable = { };			-- Holder for past exp values
		self.ExpTableMaxSize = 10;		-- How many values to track
		self.ExpInsertPos = 0;			-- Pointer to current position to overwrite (do not change)
		self.ExpPerMin = 0;				-- Calculated exp per minute
		self.TimeTillLevel = 0;			-- Time in minutes until the player will level up


		-- Directed more at player, but may be changed later.
		--self.Class3 = CLASS_NONE;
		--self.Level3 = 1;
		self.Pet = nil;
		self.PetPtr = 0;
		self.IgnoreTarget = 0;
		self.Battling = false; -- The actual "in combat" flag.
		self.Fighting = false; -- Internal use, does not depend on the client's battle flag
		self.Stance = 0;
		self.Nature = 0;
		self.Psi = 0;

		--TODO:We make a  class called POTION out of this
		--self.PotionLastUseTime = 0;
		--self.PotionHpUsed = 0;			-- counts use of HP over time potions
		--self.PotionManaUsed = 0;		-- counts use of mana over time potions
		--self.PotionLastManaEmptyTime = 0;	-- timer for potion empty message
		--self.PotionLastHpEmptyTime = 0;	-- timer for potion empty message

		--self.PotionLastOnceUseTime = 0;
		--self.PotionHpOnceUsed = 0;			-- counts use of HP potions
		--self.PotionManaOnceUsed = 0;		-- counts use of mana potions
		--self.PotionLastManaOnceEmptyTime = 0;	-- timer for potion empty message
		--self.PotionLastHpOnceEmptyTime = 0;	-- timer for potion empty message

		--self.PhiriusLastUseTime = 0;
		--self.PhiriusHpUsed = 0;			-- counts use of HP phirius
		--self.PhiriusManaUsed = 0;		-- counts use of mana phirius
		--self.PhiriusLastManaEmptyTime = 0;	-- timer for phirius empfty message
		--self.PhiriusLastHpEmptyTime = 0;	-- timer for phirius empfty message

		self.Returning = false;		-- Whether following the return path, or regular waypoints
		self.BotStartTime = os.time(); -- Records when the bot was started.
		self.BotStartTime_nr = 0;	-- Records when the bot was started, will not return at pause
		self.InventoryLastUpdate = os.time(); -- time of the last full inventory updata
		self.InventoryDoUpdate = false;	-- flag to 'force' inventory update
		self.Unstick_counter = 0;	-- counts unstick tries, resets if waypoint reached
		self.Success_waypoints = 0; -- count consecutively successfull reached waypoints
		self.Cast_to_target = 0;	-- count casts to our enemy target
		self.level_detect_levelup = 0;	-- remember player level to detect levelups
		self.Sleeping = false;		-- sleep mode with fight back if attacked
		self.Sleeping_time = 0;		-- counts the sleeping time
		self.Fights = 0;			-- counts the fights
		self.mobs = {};				-- counts the kills per target name
		self.Death_counter = 0;		-- counts deaths / automatic reanimation
		self.Current_waypoint_type = WPT_NORMAL;	-- remember current waypoint type global
		self.LastTargetPtr = 0;		-- last invalid target
		self.LastDistImprove = os.time();	-- unstick timer (dist improvement timer)
		self.FightStartTime = 0;				-- time fight started
		self.ranged_pull = false;			-- ranged pull phase active
		self.free_debug1 = 0;				-- free field for debug use
		self.free_field1 = nil;				-- free field for user use
		self.free_field2 = nil;				-- free field for user use
		self.free_field3 = nil;				-- free field for user use
		self.free_counter1 = 0;				-- free counter for user use
		self.free_counter2 = 0;				-- free counter for user use
		self.free_counter3 = 0;				-- free counter for user use
		self.free_flag1 = false;			-- free flag for user use
		self.free_flag2 = false;			-- free flag for user use
		self.free_flag3 = false;			-- free flag for user use
		self.SkillQueue = {};				-- Holds any queued skills, obviously
		self.ActualSpeed = 0
		self.Moving = false
		self.GlobalCooldown = 0
		self.LastSkill = {}
		self.failed_casts_in_a_row = 0
		self.MobIgnoreList = {}
		self.LastHitTime = 0

		if( self.Address ~= 0 and self.Address ~= nil ) then self:update(); end
	end, false -- false = do not call pawn constructor
);


function CPlayer.new()
	local playerAddress = memoryReadRepeat("uintptr", getProc(), addresses.staticbase_char, addresses.charPtr_offset);
	local np = CPlayer(playerAddress);
	np:initialize();
	np:update();
	return np;
end

function CPlayer:update()
	local addressChanged = false
	local zoned = false
	-- Ensure that our address hasn't changed. If it has, fix it.

	-- Read the address
	local tmpAddress = memoryReadRepeat("uintptr", getProc(), addresses.staticbase_char, addresses.charPtr_offset) or 0;

	-- Bad read, return
	if tmpAddress == 0 then
		return
	end

	-- Check that it's a valid address by checking the id
	local tmpId = memoryReadRepeat("uint", getProc(), tmpAddress + addresses.pawnId_offset) or 0
	if players.funcs["player_eval_id"](tmpId) then
		-- invalid address
		local counter_error = 0;
		-- TODO: recheck the error if their is a better solution possible a flag argument or return value?
		-- TODO: do it for the rest too
		-- loop invariants ( 9 < 10) => 0-> 9 = 10 tries
		while(counter_error < 10 or players.funcs["player_eval_id"](tmpId))do
			tmpId = memoryReadRepeat("uint", getProc(), tmpAddress + addresses.pawnId_offset) or 0
			rest(1000)
			counter_error = counter_error + 1;
		end

		error("Player update failed");
	end

	-- Else address good. If changed, update.
	if( tmpAddress ~= self.Address) then
		self.Address = tmpAddress;
		cprintf(cli.green, language[40], self.Address);
		addressChanged = true
		players.funcs["player_address_changed"](self);
	end;

	local oldClass1 = self.Class1
	local oldClass2 = self.Class2
	CPawn.update(self); -- run base function
	local classChanged = self.Class1 ~= oldClass1 or self.Class2 ~= oldClass2
	local newLoad = settings.profile.skills == nil

	-- Check if we need to load the skill set.
	if next(settings.profile.skillsData) ~= nil then -- The skills are ready to be loaded
		if addressChanged or classChanged or newLoad then
			settings.loadSkillSet(self.Class1)
			if newLoad then
				-- Reset editbox false flag on start up
				players.funcs["player_newload_skills"](self)
			end
			if classChanged and self.TargetPtr ~= 0 then
				self:clearTarget()
			end
			if( addressChanged == true)then
				zoned = true;
			end

			addressChanged = false
		end
	end




	self:updateClasses()
	self:updateLevels()
	self:updateXP()
	self:updateTP()
	self:updateCasting()
	self:updateBattling()
	self:updateStance() -- Also updates Stance2
	self:updateActualSpeed() -- Also updates Moving
	self:updateNature()

	if( self.Casting == nil or self.Battling == nil or self.Direction == nil ) then
		error("Error reading memory in CPlayer:update()");
	end

	self.PetPtr = memoryReadRepeat("uint", getProc(), self.Address + addresses.pawnPetPtr_offset) or self.PetPtr
	if( self.Pet == nil ) then
		self.Pet = CPawn(self.PetPtr);
	else
		self.Pet.Address = self.PetPtr;
		if( self.Pet.Address ~= 0 ) then
			self.Pet:update();
		end
	end
	self:updatePsi()
	self:updateGlobalCooldown()
	if(zoned == true)then
		--new event onZoneChange
		if( type(settings.profile.events.onZoneChange) == "function" ) then
			local status,err = pcall(settings.profile.events.onZoneChange);
			if( status == false ) then
				local msg = sprintf(language[555], err);--555 new error message
				error(msg);
			end
		end
		addressChanged2 = false;
	end
end

function CPlayer:updateXP()
	self.XP = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* self.Class1 ) + addresses.charClassInfoXP_offset) or self.XP
end

function CPlayer:updateTP()
	self.TP = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* self.Class1 ) + addresses.charClassInfoTP_offset) or self.TP
end
function CPlayer:exists()
	local id = memoryReadRepeat("uint", getProc(), self.Address + addresses.pawnId_offset)
	if id and id >= PLAYERID_MIN and PLAYERID_MAX >= id then
		self.Id = id
		return true
	else
		return false
	end
end

function CPlayer:checkAddress()
	local tmpAddress = memoryReadRepeat("uintptr", getProc(), addresses.staticbase_char, addresses.charPtr_offset) or 0;
	if( tmpAddress ~= self.Address and tmpAddress ~= 0 ) then
		self:update()
	end
end

function CPlayer:updateCasting()
	self.Casting = (memoryReadRepeat("intptr", getProc(), addresses.castingBarPtr, addresses.castingBar_offset) ~= 0);
end

function CPlayer:updateBattling()
	self.Battling = memoryReadRepeat("byteptr", getProc(), addresses.staticbase_char, addresses.charBattle_offset) == 1;

	-- remember aggro start time, used for timed ranged pull
	if( self.Battling == true ) then
		if(self.aggro_start_time == 0) then
			self.aggro_start_time = os.time();
		end
	else
		self.aggro_start_time = 0;
	end
end

function CPlayer:updateStance()
	self.Stance = memoryReadRepeat("byteptr", getProc(), addresses.staticbase_char, addresses.charStance_offset) or self.Stance
	self.Stance2 = memoryReadRepeat("byteptr", getProc(), addresses.staticbase_char, addresses.charStance_offset + 2) or self.Stance2
end

function CPlayer:updateActualSpeed()
	self.ActualSpeed = memoryReadFloatPtr(getProc(), addresses.staticbase_char, addresses.actualSpeed_offset) or self.ActualSpeed
	self.Moving = (self.ActualSpeed > 0)
end

function CPlayer:updateNature()
	local tmp = self:getBuff(503827)
	if tmp then -- has natures power
		self.Nature = tmp.Level + 1
	else
		self.Nature = 0
	end
end

function CPlayer:updatePsi()
	self.Psi = memoryReadRepeat("uint",getProc(), addresses.psi)
end

function CPlayer:updateGlobalCooldown()
	self.GlobalCooldown = memoryReadRepeat("int", getProc(), addresses.staticCooldownsBase)/10
end
function CPlayer:updateLevels()
	--[[TODO: move to Levels]]
	self.Level = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* self.Class1 ) + addresses.charClassInfoLevel_offset) or self.Level
	self.Level2 = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* self.Class2 ) + addresses.charClassInfoLevel_offset) or self.Level2
	self.Level3 = memoryReadRepeat("int", getProc(), addresses.charClassInfoBase + (addresses.charClassInfoSize* self.Class3 ) + addresses.charClassInfoLevel_offset) or self.Level3
end
function CPlayer:updateClasses()
	-- If have 2nd class, look for 3rd class
	-- Class1 and Class2 are done in the pawn class. Class3 only works for player.
	if self.Classes[2] ~= -1 then
		for i = 1, 8 do
			local level = memoryReadInt(getProc(),addresses.charClassInfoBase + (addresses.charClassInfoSize * i) + addresses.charClassInfoLevel_offset)
			if level > 0 and i ~= self.Class1 and i ~= self.Class2 then
				-- must be class 3
				self.Class3 = i
				break
			end
		end
	end

end

-- Returns nil if nothing found, otherwise returns a pawn
function CPlayer:findEnemy(aggroOnly, _id, evalFunc, ignore)
	-- If aggroonly, check to see if you have already started attacking current target
	if aggroOnly then
		if self:haveTarget() then
			local target = CPawn.new(self.TargetPtr)
			target:updateLastHP()
			if target.TargetPtr == self.Address or
				target:targetIsFriend() or
				target.LastHP > 0 then
				return target
			end
		end
	end

	-- Otherwise look for target
	self:updateXYZ()
	ignore = ignore or 0;
	local aggroOnly = aggroOnly or false;
	local bestEnemy = nil;
	local bestScore = 0;
	local obj = nil;
	local objectQueue = CObjectQueue();
	objectQueue:update();

	if( type(evalFunc) ~= "function" ) then
		evalFunc = function (unused) return true; end;
	end

	-- The 'max' values that each scoring sub-part uses
	local SCORE_DISTANCE = 60;      -- closer = more score; actually score will usually be less than half
	local SCORE_AGGRESSIVE = 80;    -- aggressive = score
	local SCORE_ATTACKING = 200;    -- attacking = score
	local SCORE_HEALTHPERCENT = 75; -- lower health = more score

	while(objectQueue:peek(PT_MONSTER)) do
		obj = objectQueue:poll(PT_MONSTER);
		if( (_id == obj.Id or _id == nil) and obj.Address ~= ignore) then
			local dist = distance(self.X, self.Z, obj.X, obj.Z)
			if dist < settings.profile.options.MAX_TARGET_DIST then
				local pawn = CPawn.new(obj.Address);
				pawn:updateTargetPtr()
				if( evalFunc(pawn.Address, pawn) == true and pawn.Attackable) then
					pawn:updateXYZ()
					pawn:updateInParty()
					if ((pawn.TargetPtr == self.Address or pawn:targetIsFriend()) and
						aggroOnly == true) or aggroOnly == false then
						local currentScore = 0;
						pawn:updateHP()
						currentScore = currentScore + ( (settings.profile.options.MAX_TARGET_DIST - dist) / settings.profile.options.MAX_TARGET_DIST * SCORE_DISTANCE );
						currentScore = currentScore + ( (pawn.MaxHP - pawn.HP) / pawn.MaxHP * SCORE_HEALTHPERCENT );
						if( pawn.TargetPtr == self.Address or pawn:targetIsFriend() ) then currentScore = currentScore + SCORE_ATTACKING; end;
						if( pawn.Aggressive ) then
							currentScore = currentScore + SCORE_AGGRESSIVE;
						end;
						if( bestEnemy == nil ) then
							bestEnemy = obj;
							bestScore = currentScore;
						elseif( currentScore > bestScore ) then
							bestEnemy = obj;
							bestScore = currentScore;
						end
					end
				end
			end
		end
	end

	if( bestEnemy ) then
		return CPawn(bestEnemy.Address);
	else
		return nil;
	end
end
--TODO: change to task
local function RestWhileCheckingForWaypoint(_duration)
	player:updateActualSpeed()
	if #__WPL.Waypoints > 0 and player.Moving and not player.Fighting then
		-- rest for _duration but if moving stop when reaching waypoint
		local starttime = os.clock()
		local curWP = __WPL.Waypoints[__WPL.CurrentWaypoint]
		local lastdist = distance(player.X,player.Z,curWP.X, curWP.Z)
		repeat
			local startdist = lastdist
			yrest(10)
			player:updateXYZ()
			lastdist = distance(player.X, player.Z, curWP.X, curWP.Z)
			if (lastdist < 10 or lastdist > startdist) then -- and wp reached or moving away
				return false
			end
		until (os.clock() - starttime) > _duration/1000
	else
		yrest(_duration)
	end
	return true
end
-- Basic target evaluation.
-- Returns true if a valid target, else false.
function evalTargetDefault(address, target)
	if not target then
		target = CPawn.new(address);
	end

	--== Helper Functions ==--
	--------------------------

	local function debug_target(_place)
		if settings.profile.options.DEBUG_TARGET and
			player.TargetPtr ~= player.LastTargetPtr then
			cprintf(cli.yellow, "[DEBUG] "..(target.Address or 0).." ".._place.."\n");
			player.LastTargetPtr = player.TargetPtr;		-- remember target address to avoid msg spam
		end
	end

	local function printNotTargetReason(_reason)
		if( player.TargetPtr ~= player.LastTargetPtr ) then
			cprintf(cli.yellow, "%s\n", _reason);
			player.LastTargetPtr = player.TargetPtr;		-- remember target address to avoid msg spam
		end
	end

	--== First do checks that target is valid and alive ==--
	--------------------------------------------------------


	-- Check if still valid target
	if not target:exists() then
		debug_target("target is no longer valid")
		return false
	end

	-- Can't have self as target
	if( address == player.Address ) then
		debug_target("Can't have self as target")
		return false;
	end

	-- Not attackable
	target:updateAttackable()
	if( not target.Attackable ) then
		debug_target("target is not attackable")
		return false;
	end

	-- Dead
	target:updateHP()
	if( target.HP < 1 ) then
		debug_target("target HP is less than 1")
		return false;
	end

	-- Also dead (and has loot)
	target:updateLootable()
	if( target.Lootable ) then
		debug_target("target is lootable therefore dead")
		return false;
	end

	target:updateAlive()
	if( not target.Alive ) then
		debug_target("target is not Alive")
		return false;
	end

	--== Check aggro ==--
	---------------------

	target:updateTargetPtr()
	target:updateType()
	player:updateBattling()
	if player.Battling then -- Battling flag is on
		if target.TargetPtr == player.Address or -- We are being targeted
			target:targetIsFriend(true) then -- Or friend is being targeted
		if target.Type ~= PT_PLAYER or settings.profile.options.PVP ~= false then --  Check PVP
			return true
			end
	end
	end

	--== Non aggro checks ==--
	--------------------------

	-- don't target NPCs
	if( target.Type == PT_NPC ) then      -- NPCs are type == 4
		debug_target("thats a NPC, he should be friendly and not attackable")
		return false;         -- he is not a valid target
	end;

	-- Check height difference
	target:updateXYZ()
	player:updateXYZ()

	if( not settings.profile.options.DROPHEIGHT)then
		settings.profile.options.DROPHEIGHT = 35;
	end

	if( math.abs(target.Y - player.Y) > settings.profile.options.DROPHEIGHT ) then
		debug_target("target height difference is too great")
		return false;
	end

	-- check level of target against our leveldif settings
	target:updateLevel()
	if( ( target.Level - player.Level ) > tonumber(settings.profile.options.TARGET_LEVELDIF_ABOVE)  or
		( player.Level - target.Level ) > tonumber(settings.profile.options.TARGET_LEVELDIF_BELOW)  ) then
		debug_target("target lvl above/below profile settings without battling")
		return false;			-- he is not a valid target
	end;

	-- check if on the ignore list
	if target:isOnMobIgnoreList() then
		target:updateName()
		cprintf(cli.green, language[87], target.Name);
		debug_target("ignore target (e.g. after doing no damage")
		return false
	end

	-- check distance to target against MAX_TARGET_DIST
	if( distance(player.X, player.Z, player.Y, target.X, target.Z, target.Y) > settings.profile.options.MAX_TARGET_DIST ) then
		debug_target("target dist > MAX_TARGET_DIST to player")
		return false;			-- he is not a valid target
	end;

	-- check if in assigned kill zone
	if (not player.Returning) and #__WPL.KillZone > 0 and not PointInPoly(__WPL.KillZone, target.X, target.Z) then
		debug_target("target outside KillZone")
		return false;			-- he is not a valid target
	end

	-- check if in one of the exclude zones
	if (not player.Returning) and next(__WPL.ExcludeZones) then
		for zonename,zone in pairs(__WPL.ExcludeZones) do
			if PointInPoly(zone, target.X, target.Z) then
				debug_target("target inside an exclude zone")
				return false;			-- he is not a valid target
			end
		end
	end

	-- check target distance to path against MAX_TARGET_DIST
	local wpl; -- this is the waypoint list we're using
	local V; -- this is the point we will use for distance checking

	if( player.Returning ) then
		wpl = __RPL;
	else
		wpl = __WPL;
	end

	if (__WPL:getMode() == "waypoints") and #__WPL.Waypoints > 0 then
		local pA = wpl.Waypoints[wpl.LastWaypoint]
		local pB = wpl.Waypoints[wpl.CurrentWaypoint]

		V = getNearestSegmentPoint3D(player.X, player.Z, player.Y, pA.X, pA.Z, pA.Y, pB.X, pB.Z, pB.Y);
	else
		V = CWaypoint(player.X, player.Z, player.Y); -- Distance check from player in wander mode
	end

	-- use a bounding box first to avoid sqrt when not needed (sqrt is expensive)
	if( distance(V.X, V.Z, V.Y ,target.X, target.Z, target.Y) > settings.profile.options.MAX_TARGET_DIST and not (distance(player.X, player.Z, player.Y, target.X, target.Z, target.Y) <= 100) ) then
		debug_target("target dist > MAX_TARGET_DIST to waypoint")
		return false;			-- he is not a valid target
	end


	-- PK protect
	if settings.profile.options.PVP == false then
		if( target.Type == PT_PLAYER ) then
			debug_target("target is a player. PVP is off.")
			return false;
		end
	elseif settings.profile.options.PVP ~= true then
		if( target.Type == PT_PLAYER ) then      -- Player are type == 1
			debug_target("PK player, but not fighting us")
			return false;         -- he is not a valid target
		end;
	end

	-- Ignore pets
	target:updateIsPet()
	if target.IsPet then
		debug_target("target is a pet")
		return false
	end

	-- Friends aren't enemies
	if( target:isFriend() ) then
		debug_target("target is a friend")
		return false;		-- he is not a valid target
	end;

	-- Mob limitations defined?
	if( #settings.profile.mobs > 0 ) then
		if( player:isInMobs(target) == false ) then
			debug_target("mob limitation is set, mob is not a valid target")
			return false;		-- he is not a valid target
		end
	end;

	-- target is to strong for us
	if (settings.profile.options.PARTY_INSTANCE ~= true ) then
		if( target.MaxHP > player.MaxHP * settings.profile.options.AUTO_ELITE_FACTOR ) then
			--				debug_target("target is to strong. More HP then self.MaxHP * settings.profile.options.AUTO_ELITE_FACTOR")
			printNotTargetReason("Target is to strong. More HP then player.MaxHP * settings.profile.options.AUTO_ELITE_FACTOR")
			return false;		-- he is not a valid target
		end;
	end

	if( settings.profile.options.ANTI_KS ) then
		target:updateTargetPtr()
		if target.TargetPtr ~= player.Address and not target:targetIsFriend() then
			-- If the target's TargetPtr is 0,
			-- that doesn't necessarily mean they don't
			-- have a target (game bug, not a bug in the bot)
			if( target.TargetPtr == 0 ) then
				if( target.HP < target.MaxHP ) then
					debug_target("anti kill steal: target not fighting us: unknown target")
					return false;
				end
			else
				local targettarget = CPawn.new(target.TargetPtr)
				targettarget:updateType()
				if targettarget.Type == PT_PLAYER then
					-- They definitely target another player.
					-- If it is a friend, we can help.
					-- Otherwise, leave it alone.
					debug_target("anti kill steal: target not fighting us: target isn't targeting a friend")
					return false;
				end
			end
		end
	end

	return true;
end
function evalTargetLootable(address, target)

	if not target or not target.HP then
		target = CPawn.new(address)
	end
	-- Check if still valid target
	if not target:exists() then
		return false
	end

	-- Check if lootable
	target:updateLootable()
	if not ( target.Lootable ) then
		return false;
	end

	-- Check if in lootIgnoreList
	for __, addr in pairs(lootIgnoreList) do
		if target.Address == addr then
			return false
		end
	end

	-- Check height difference
	target:updateXYZ()
	if(not settings.profile.options.DROPHEIGHT)then
		settings.profile.options.DROPHEIGHT = 35;
	end

	if( math.abs(target.Y - player.Y) > settings.profile.options.DROPHEIGHT ) then
		return false;
	end

	-- check distance to target
	local dist = distance(player.X, player.Z, player.Y, target.X, target.Z, target.Y);
	local lootdist = 100;

	-- Set to combat distance; update later if loot distance is set
	if( settings.profile.options.COMBAT_TYPE == "ranged" ) then
		lootdist = settings.profile.options.COMBAT_DISTANCE;
	end

	if( settings.profile.options.LOOT_DISTANCE ) then
		lootdist = settings.profile.options.LOOT_DISTANCE;
	end

	if( dist > lootdist ) then 	-- only loot when close by
		return false
	end

	-- check target distance to path against MAX_TARGET_DIST
	local wpl; -- this is the waypoint list we're using
	local V; -- this is the point we will use for distance checking

	if( player.Returning ) then
		wpl = __RPL;
	else
		wpl = __WPL;
	end

	if (__WPL:getMode() == "waypoints") and #__WPL.Waypoints > 0 then
		local pA = wpl.Waypoints[wpl.LastWaypoint]
		local pB = wpl.Waypoints[wpl.CurrentWaypoint]

		V = getNearestSegmentPoint(player.X, player.Z, player.Y, pA.X, pA.Z, pA.Y, pB.X, pB.Z, pB.Y);
	else
		V = CWaypoint(player.X, player.Z, player.Y); -- Distance check from player in wander mode
	end

	-- use a bounding box first to avoid sqrt when not needed (sqrt is expensive)
	if( distance(V.X, V.Z, V.Y, target.X, target.Z, target.Y) > lootdist and not (distance(player.X, player.Z, player.Y, target.X, target.Z, target.Y) <= 100) ) then
		if( settings.profile.options.DEBUG_LOOT) then
			cprintf(cli.yellow, "unlooted monster dist > lootdist")
		end
		return false;			-- he is not a valid target
	end;


	return true
end
function CPlayer:findNearestNameOrId(_objtable, ignore, evalFunc)
	if type(_objtable) == "number" or type(_objtable) == "string" then
		_objtable = {_objtable}
	end
	local foundobjects = {}
	ignore = ignore or 0;
	local closestObject = nil;
	local obj = nil;
	local objectQueue = CObjectQueue();
	objectQueue:update();

	if( type(evalFunc) ~= "function" ) then
		evalFunc = function (unused) return true; end;
	end

	self:updateXYZ()
	while(objectQueue:peek()) do
		obj = objectQueue:poll()
		for __, _objnameorid in pairs(_objtable) do
			if( obj.Address ~= ignore and obj.Address ~= self.Address and (obj.Id == tonumber(_objnameorid) or string.find(obj.Name, _objnameorid, 1, true) )) then
				if( evalFunc(obj.Address,obj) == true ) then
					obj.Distance = distance(obj,self)
					table.insert(foundobjects,obj)
				end
			end
		end
	end
	-- sort by distance
	local function distancesortfunc(a,b)
		return b.Distance > a.Distance
	end
	if #foundobjects ~= 0 then -- sort according to distance first
		table.sort(foundobjects, distancesortfunc)
		return foundobjects[1], foundobjects -- return closest object, return all objects found
	end
	return -- means you found nothing, so returns nil
end
function CPlayer:lootAll(task)

	if( settings.profile.options.LOOT ~= true ) then
		if( settings.profile.options.DEBUG_LOOT) then
			cprintf(cli.yellow, "[DEBUG] don't loot all reason: settings.profile.options.LOOT ~= true\n");
		end;
		return
	end

	if( settings.profile.options.LOOT_ALL ~= true ) then
		if( settings.profile.options.DEBUG_LOOT) then
			cprintf(cli.yellow, "[DEBUG] don't loot all reason: settings.profile.options.LOOT_ALL ~= true\n");
		end;
		return
	end

	-- Warn user if they still have 'lootbodies()' userfunction installed.
	if type(lootBodies) == "function" then
		cprintf(cli.yellow,"The userfunction 'lootBodies()' is obsolete and might interfere with the bots 'lootAll()' function. Please delete the 'addon_lootbodies.lua' file from the 'userfunctions' folder.\n")
	end



	-- Check if inventory is full. We don't loot if inventory is full.
	if inventory:itemTotalCount(0) == 0 then
		if( settings.profile.options.DEBUG_LOOT) then
			cprintf(cli.yellow, "[DEBUG] don't loot all reason: inventory is full\n");
		end;
		return
	end

	self:updateBattling()
	if( self.Battling  and
		self:findEnemy(true,nil,evalTargetDefault)) then
		return STATE_FAILED;
	end

	local Lootable = self:findNearestNameOrId("", nil, evalTargetLootable)

	if Lootable == nil then
		return STATE_SUCCESS;
	else
		Lootable = CPawn(Lootable.Address)
	end

	self:target(Lootable)
	self:updateTargetPtr()
	if self.TargetPtr ~= 0 then -- Target's still there.
		self:loot()
		if self:findEnemy(true, nil, evalTargetDefault) then
			-- not looting because of aggro
			return
		end
		yrest(50)
		Lootable:updateLootable();
		if Lootable.Lootable == true then
			-- Failed to loot. Add to ignore list
			lootIgnoreListPos = lootIgnoreListPos + 1
			if lootIgnoreListPos > settings.profile.options.LOOT_IGNORE_LIST_SIZE then lootIgnoreListPos = 1 end
			lootIgnoreList[lootIgnoreListPos] = Lootable.Address
		end
	end
	return STATE_PENNDING;
end
function CPlayer:moveTo(task, waypoint, ignoreCycleTargets, dontStopAtEnd, range)
	Movement:moveTo(task, waypoint,ignoreCycleTargets, dontStopAtEnd, range)
end
function CPlayer:fight(task)

end
--[[TODO: Over work for task run possible change it to AI solution]]
-- Attempt to unstick the player
function CPlayer:unstick(task)
	-- after 2x unsuccesfull unsticks try to reach last waypoint
	if( self.Unstick_counter == 3 ) then
		if unStick3 then
			unStick3()
		elseif( self.Returning ) then
			__RPL:backward();
		else
			__WPL:backward();
		end;
		return;

	end


	-- after 5x unsuccesfull unsticks try to reach next waypoint after sticky one
	if( self.Unstick_counter == 6 ) then
		if unStick6 then
			unStick6()
		elseif( self.Returning ) then
			__RPL:advance();	-- forward to sticky wp
			__RPL:advance();	-- and one more
		else
			__WPL:advance();	-- forward to sticky wp
			__WPL:advance();	-- and one more
		end;
		return;

	end


	-- after 8x unstick try to run away a little and then go to the nearest waypoint
	if( self.Unstick_counter == 9 ) then
		if unStick9 then
			unStick9()
		else
			-- turn and move back for 10 seconds
			keyboardHold(settings.hotkeys.ROTATE_RIGHT.key);
			yrest(1900);
			keyboardRelease( settings.hotkeys.ROTATE_RIGHT.key );
			keyboardHold(settings.hotkeys.MOVE_FORWARD.key);
			yrest(10000);
			keyboardRelease(settings.hotkeys.MOVE_FORWARD.key);
			self:updateXYZ();
			if( self.Returning ) then
				__RPL:setWaypointIndex(__RPL:getNearestWaypoint(self.X, self.Z));
			else
				__WPL:setWaypointIndex(__WPL:getNearestWaypoint(self.X, self.Z));
			end;
			return;
		end;
	end

	-- Move back for x seconds
	keyboardHold(settings.hotkeys.MOVE_BACKWARD.key);
	yrest(1000);
	keyboardRelease(settings.hotkeys.MOVE_BACKWARD.key);

	-- Straff either left or right now
	local straffkey = 0;
	if( math.random(100) < 50 ) then
		straffkey = settings.hotkeys.STRAFF_LEFT.key;
	else
		straffkey = settings.hotkeys.STRAFF_RIGHT.key;
	end

	local straff_bonus = self.Unstick_counter * 120;
	keyboardHold(straffkey);
	yrest(500 + math.random(500) + straff_bonus);
	keyboardRelease(straffkey);

	-- try to jump over a obstacle
	if( self.Unstick_counter > 1 ) then
		if( self.Unstick_counter == 2 ) then
			keyboardHold(settings.hotkeys.MOVE_FORWARD.key);
			yrest(550);
			keyboardPress(settings.hotkeys.JUMP.key);
			yrest(400);
			keyboardRelease(settings.hotkeys.MOVE_FORWARD.key);
		elseif( math.random(100) < 80 ) then
			keyboardHold(settings.hotkeys.MOVE_FORWARD.key);
			yrest(600);
			keyboardPress(settings.hotkeys.JUMP.key);
			yrest(400);
			keyboardRelease(settings.hotkeys.MOVE_FORWARD.key);
		end;
	end;

end
-- returns true if target is in mobs
function CPlayer:isInMobs(pawn)
	if( not pawn ) then
		error("CPlayer:isInMobs() received nil\n", 2);
	end;

	if not pawn:exists() then
		return false
	end

	pawn:updateName()
	for i,v in pairs(settings.profile.mobs) do
		if( string.find( string.lower(pawn.Name), string.lower(v), 1, true) ) or tonumber(v) == pawn.Id then
			return true;
		end
	end

	return false;
end
function CPlayer:addToMobIgnoreList(target)
	if type(target) == "table" then
		table.insert(self.MobIgnoreList,{Address=target.Address,Time=os.clock()})
	else
		table.insert(self.MobIgnoreList,{Address=target,Time=os.clock()})
	end
	self:updateXYZ()
	self.LastPlaceMobIgnored = {X=self.X,Z=self.Z,Y=self.Y}
end

function CPlayer:clearMobIgnoreList()
	self:updateXYZ()
	-- Only clear list if you have traveled 50 from last ignore
	if self.LastPlaceMobIgnored == nil or distance(self,self.LastPlaceMobIgnored) > 50 then
		self.MobIgnoreList = {}
	end
end
