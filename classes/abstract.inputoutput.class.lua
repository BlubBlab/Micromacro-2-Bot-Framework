CAbstractInputOutput = class(
	function (self, procHandle))
		self.procHandle = procHandle	
	end
);

function CAbstractInputOutput:read(Handle, type, Address  )
	local result = nil;
	local counter = 1;
	local limit = 50;
	
	repeat	
		result = process.read(Handle, type, Address)
		counter = counter + 1
	until counter >= limit or result ~= nil
		
	return result;
end

function CAbstractInputOutput:readPtr(Handle, type, Address, offset  )
	local result = nil;
	local counter = 1;
	local limit = 50;
	
	repeat	
		result = process.readPtr(Handle, type, Address, offset)
		counter = counter + 1
	until counter >= limit or result ~= nil
		
	return result;
end
-- objects
function CAbstractInputOutput:ObjectId(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnId_offset ) or 0;
end

function CAbstractInputOutput:ObjectType(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnType_offset ) or -1;
end

function CAbstractInputOutput:ObjectNamePtr(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnName_offset )
end

function CAbstractInputOutput:ObjectName(visitor)
	return self:read(self.procHandle, "string", visitor:getAddress() )
end

function CAbstractInputOutput:ObjectPosition(select, visitor)
	
	if(string.lower(select) == "x" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnX_offset ) or 0;
	elseif string.lower(select) == "y" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnY_offset ) or 0;
	elseif string.lower(select) == "z" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnZ_offset ) or 0;
	end
	error("not specific coordinate type");
end

-- object lists
function CAbstractInputOutput:ObjectListSize(visitor)
	return self:read(self.procHandle, "int", addresses.staticTableSize );
end

function CAbstractInputOutput:ObjectListPtr(mult)
	-- 4 = 4 byte = 32-bit pointer
	return self:readPtr(self.procHandle, "uint", addresses.staticTableSize,mult * 4 );
end
-- pawns
function CAbstractInputOutput:PawnId(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnId_offset) or 0;
end

function CAbstractInputOutput:PawnRace(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnRace_offsett);
end

function CAbstractInputOutput:PawnAttackable(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnAttackable_offset);
end
-- same as object but if somebody use with another game maybe it is diffrent
function CAbstractInputOutput:PawnNamePtr(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnName_offset )
end
-- again same as object and same reason to let it be
function CAbstractInputOutput:PawnName(visitor)
	return self:read(self.procHandle, "string", visitor:getAddress() )
end

function CAbstractInputOutput:PawnGUID(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnGUID_offset )
end

function CAbstractInputOutput:PawnType(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnType_offset )
end

function CAbstractInputOutput:PawnIsAlive(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.charAlive_offset )
end

function CAbstractInputOutput:PawnIsFading(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnFading_offset )
end

function CAbstractInputOutput:PawnHP(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnHP_offset )
end

function CAbstractInputOutput:PawnMaxHP(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxHP_offset )
end

function CAbstractInputOutput:PawnLastHP(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLastHP_offset )
end

function CAbstractInputOutput:PawnClass(select, visitor)
	local class;
	if( select == 1 )then
		class = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass1_offset )
	elseif( select == 2 )then
		class = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass2_offset )
	elseif( select == 3 )then
		class = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass3_offset )
	else
		error("not a class index for: "..select.."");
	end
	return class;
end

function CAbstractInputOutput:PawnEnergy(select, visitor)
	local energy;
	if( select == 1 )then
		energy = self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMP_offset )
	elseif( select == 2)then
		energy = self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMP2_offset )
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CAbstractInputOutput:PawnMaxEnergy(select, visitor)
	local energy;
	if( select == 1 )then
		energy = self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxMP_offset )
	elseif( select == 2)then
		energy = self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxMP2_offset )
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CAbstractInputOutput:PawnBuffStartEnde(visitor)
	local start = self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnBuffsStart_offset );
	local ende  = self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnBuffsEnd_offset );
	return start , ende;
end

function CAbstractInputOutput:PawnBuffID(i, visitor)
	return = self:read(self.procHandle, "uint", visitor:getAddress() +  i + addresses.pawnBuffId_offset );
end

function CAbstractInputOutput:PawnBuffTimeLeft(i , visitor)
	return = self:read(self.procHandle, "float", visitor:getAddress() + i + addresses.pawnBuffTimeLeft_offset );
end

function CAbstractInputOutput:PawnBuffLevel(i , visitor)
	return = self:read(self.procHandle, "float", visitor:getAddress() + i + addresses.pawnBuffLevel_offset );
end

function CAbstractInputOutput:PawnLootable(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnLootable_offset )
end

function CAbstractInputOutput:PawnHarvesting(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnHarvesting_offset )~=0
end

function CAbstractInputOutput:PawnCasting(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnCasting_offset )~=0
end

function CAbstractInputOutput:PawnLevel(select, visitor)
	local level;
	if( select == 1 )then
		level = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel_offset )
	elseif( select == 2 )then
		level = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel2_offset )
	elseif( select == 3 )then
		level = self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel3_offset )
	else
		error("not a level index for: "..select.."");
	end
	return level;
end

function CAbstractInputOutput:PawnTargetPtr(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnTargetPtr_offset ) or 0
end
-- again double
function CAbstractInputOutput:PawnPosition(select, visitor)
	
	if(string.lower(select) == "x" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnX_offset );
	elseif string.lower(select) == "y" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnY_offset );
	elseif string.lower(select) == "z" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnZ_offset );
	end
	error("not specific coordinate type");
	
end

function CAbstractInputOutput:PawnDirection(select, visitor)
	
	if(string.lower(select) == "x" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirXUVec_offset );
	elseif string.lower(select) == "z" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirZUVec_offset );
	elseif string.lower(select) == "y" )then
		return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirYUVec_offset );
	end
	error("not specific direction  type");

end

function CAbstractInputOutput:PawnSwimming(visitor)
	return self:readPtr(self.procHandle, "byte", visitor:getAddress() + addresses.pawnSwim_offset1, addresses.pawnSwim_offset2 );
end

function CAbstractInputOutput:PawnIsPet(visitor)
	return self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnIsPet_offset )
end

function CAbstractInputOutput:PawnSpeed(visitor)
	return self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnSpeed_offset )
end

function CAbstractInputOutput:PawnIconBase(visitor)
	return self:readPtr(self.procHandle, "uint", visitor:getAddress() + addresses.partyIconList_base, addresses.partyIconList_offset);
end
function CAbstractInputOutput:PawnIconRead(visitor)
	return self:read(self.procHandle, "int", visitor:getAddress())
end

function CAbstractInputOutput:PressKey(visitor, key1, key2)

	if( not key2)then
		keyboard.virtualPress(self.procHandle, key1, true);
	else
		keyboard.virtualPress(self.procHandle, key1);
	end
	
	if (key2)then
		keyboard.virtualPress(self.procHandle, key2);
	end
end

function CAbstractInputOutput:PressHold(visitor, key1, key2)

	keyboard.virtualHold(self.procHandle, key1);
	
	if (key2)then
		keyboard.virtualHold(self.procHandle, key2);
	end
end

function CAbstractInputOutput:PressRelease(visitor, key1, key2)

	keyboard.virtualRelease(self.procHandle, key1);
	
	if (key2)then
		keyboard.virtualRelease(self.procHandle, key2);
	end
end
function CAbstractInputOutput:WriteText(visitor,text)

	keyboard.keyboard.virtualTyp(self.procHandle, text);
	
end
