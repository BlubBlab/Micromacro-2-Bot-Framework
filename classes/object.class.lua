include("objects.settings.lua");

CObject = class(
	function (self, ptr)
		self.Address = ptr;
		self.Name = "<UNKNOWN>";
		self.Id = 0;
		self.Type = PT_NONE;
		self.X = 0.0;
		self.Y = 0.0;
		self.Z = 0.0;

		if( self.Address ~= 0 and self.Address ~= nil ) then self:update(); end
	end
);

function CObject:update()
	local proc = getProc();
	local memerrmsg = "Failed to read memory";
	local tmp;
	-- eval functions from objects.settings.lua
	local evalID = objects.funcs["objecte_eval_id_and_type"];
	local evalName = objects.funcs["objecte_eval_name"];
	local evalNamePtr = objects.funcs["objecte_eval_nameptr"];
	
	self.Id = memoryReadUInt(proc, self.Address + addresses.pawnId_offset) or 0;
	self.Type = memoryReadInt(proc, self.Address + addresses.pawnType_offset) or -1;

	if( evalID( self.Id, self.Type) )then -- invalid object
		self.Id = 0
		self.Type = -1
		self.Name = ""
		return;
	end

	-- Disable memory warnings for name reading only
	showWarnings(false);
	local namePtr = memoryReadRepeat("uint", proc, self.Address + addresses.pawnName_offset);
--	self.Name = debugAssert(memoryReadString(proc, namePtr), memerrmsg);
	if( evalNamePtr(  namePtr )) then
		tmp = nil;
	else
		tmp = memoryReadString(proc, namePtr);
	end
	showWarnings(true); -- Re-enable warnings after reading


	-- UTF8 -> ASCII translation not for player names
	-- because that would need the whole table and there we normaly
	-- don't need it, we don't print player names in the MM window or so
	if( evalName(tmp )) then
		self.Name = "<UNKNOWN>";
--	elseif(self.Type == PT_PLAYER ) then
--		self.Name = tmp;
	else
		-- time for only convert 8 characters is 0 ms
		-- time for convert the whole UTF8_ASCII.xml table is about 6-7 ms
--		local hf_before = getTime();

		if( bot.ClientLanguage == "RU" ) then
			self.Name = utf82oem_russian(tmp);
		else
			self.Name = utf8ToAscii_umlauts(tmp);	-- only convert umlauts
--			self.Name = convert_utf8_ascii( tmp )	-- convert the whole UTF8_ASCII.xml table
		end
--		cprintf(cli.yellow, "DEBUG utf8 %s %d\n", self.Name, deltaTime(getTime(), hf_before) );
	end

	self.X = memoryReadFloat(proc, self.Address + addresses.pawnX_offset) or 0;
	self.Y = memoryReadFloat(proc, self.Address + addresses.pawnY_offset) or 0;
	self.Z = memoryReadFloat(proc, self.Address + addresses.pawnZ_offset) or 0;

	--local attackableFlag = debugAssert(memoryReadUByte(proc, self.Address + addresses.pawnAttackable_offset)) or 0;
	--printf("attackable flag: 0x%X (%s)\n", attackableFlag, self.Name);
	--printf("check(player): %s\n", tostring( bitAnd(attackableFlag, ATTACKABLE_MASK_PLAYER) ));

	if( self.Type == PT_MONSTER ) then
		self.Attackable = true;
	else
		self.Attackable = false;
		--[[
		if( bitAnd(attackableFlag, ATTACKABLE_MASK_PLAYER) ) then
			self.Attackable = true;
		else
			self.Attackable = false;
		end]]
	end

	if( self:getAddress == nil ) then
		error("Error reading memory in CObject:update()");
	end
end
function CObject:getType()
	return self.Type;
end
function CObject:getName()
	return self.Name;
end
return CObject:getId()
	return self.Id;
end
return CObject:getPos()
	return self.X,self.Y,self.Z;
end
return CObject:getAddress()
	return self.Address;
end
return CObject:getDistance( x2, z2, y2)
	
	local x1,z1,y1 = self:getPos();
	
	if type(x2) == "table"  then
       return self:getDistance(x2:getPos())
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