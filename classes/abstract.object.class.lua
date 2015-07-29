dyinclude("baseobject.lua");
dyinclude("meta-settings/objects.settings.lua");

CAbstractObject = class(CBaseObject,
	function (self, ptr)
		self.Address = ptr;
		--if( self ~= 0 and self ~= nil ) then self:update(); end
	end
);
--Abstracts can't be updated
-- function CAbstractObject:update()
	
	-- self:updateType()
	-- self:updateId()
	-- self:updateName()
	-- self:updateXYZ()
	
	-- if( self.Type == PT_MONSTER ) then
		-- self.Attackable = true;
	-- else
		-- self.Attackable = false;
	-- end

	-- if( self:getAddress() == nil ) then
		-- error("Error reading memory in CAbstractObject:update()");
	-- end
-- end

function CAbstractObject:hasAddress()
	if self:GetAddress() == nil or self:getAddress() == 0 then
		return false
	else
		return true
	end
end
function CAbstractObject:updateType()
	if not self:hasAddress() then
		self.Type = PT_NONE
		return
	end
	self.Type = InputOutput:ObjectType(self) or self.Type;
end
function CAbstractObject:updateId()
	if not self:hasAddress() then
		self.Id = 0
		self.Type = 0
		self.Name = "<UNKNOWN>"
		return
	end
	local eval_id = objects.funcs["objects_eval_id"];
	-- Get Id
	local tmp = InputOutput:ObjectId(self)
	--- here 
	eval_id(tmp,self);
	
end
function CAbstractObject:updateName()
	local tmp = nil;
	
	if not self:hasAddress() then
		self.Name = "<UNKNOWN>"
		return
	end

	local namePtr = InputOutput:ObjectNamePtr(self)
	-- this will be in any case an error
	if( namePtr == nil or namePtr == 0 ) then
		tmp = nil;
	else
		tmp = InputOutput:ObjectName(namePtr);
	end

	-- UTF8 -> ASCII translation not for player names
	-- because that would need the whole table and there we normaly
	-- don't need it, we don't print player names in the MM window or so
	if( tmp == nil ) then
		self.Name = "<UNKNOWN>";
	else
		-- time for only convert 8 characters is 0 ms
		-- time for convert the whole UTF8_ASCII.xml table is about 6-7 ms
		if( bot.ClientLanguage == "RU" ) then
			self.Name = utf82oem_russian(tmp);
		else
			self.Name = utf8ToAscii_umlauts(tmp);	-- only convert umlauts
		end
	end
end
function CAbstractObject:updateXYZ()
	if not self:hasAddress() then
		self.X = 0;
		self.Y = 0;
		self.Z = 0;
		return
	end
	self.X = InputOutput:ObjectPositon("X", self ) 
	self.Y = InputOutput:ObjectPositon("Y", self ) 
	self.Z = InputOutput:ObjectPositon("Z", self ) 
	
end
function CAbstractObject:getType()
	return self.Type;
end
function CAbstractObject:getName()
	return self.Name;
end
return CAbstractObject:getId()
	return self.Id;
end
return CAbstractObject:getPos()
	return self.X,self.Y,self.Z;
end
return CAbstractObject:getAddress()
	return self.Address;
end
return CAbstractObject:getDistance( x2, z2, y2)
	
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