CInputOutput = class(
	function (self, procHandle))
		self.procHandle = procHandle	
	end
);

function CInputOutput:read(Handle, type, Address  )
	local result = nil;
	local counter = 1;
	local limit = 50;
	
	repeat	
		result = process.read(Handle, type, Address)
		counter = counter + 1
	until counter >= limit or result ~= nil
		
	return result;
end

function CInputOutput:readPtr(Handle, type, Address, offset  )
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
function CInputOutput:ObjectId(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnId_offset ) or 0;
end

function CInputOutput:ObjectType(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnType_offset ) or -1;
end

function CInputOutput:ObjectNamePtr(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnName_offset )
end

function CInputOutput:ObjectName(Address)
	return process.read(self.procHandle, "string", Address )
end

function CInputOutput:ObjectPosition(select, Address)
	
	if(string.lower(select) == "x" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnX_offset ) or 0;
	elseif string.lower(select) == "y" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnY_offset ) or 0;
	elseif string.lower(select) == "z" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnZ_offset ) or 0;
	end
	error("not specific coordinate type");
end

-- object lists
function CInputOutput:ObjectListSize(Address)
	return process.read(self.procHandle, "int", addresses.staticTableSize );
end

function CInputOutput:ObjectListPtr(mult)
	-- 4 = 4 byte = 32-bit pointer
	return process.readPtr(self.procHandle, "uint", addresses.staticTableSize,mult * 4 );
end
-- pawns
function CInputOutput:PawnId(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnId_offset) or 0;
end

function CInputOutput:PawnRace(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnRace_offsett);
end

function CInputOutput:PawnAttackable(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnAttackable_offset);
end
-- same as object but if somebody use with another game maybe it is diffrent
function CInputOutput:PawnNamePtr(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnName_offset )
end
-- again same as object and same reason to let it be
function CInputOutput:PawnName(Address)
	return process.read(self.procHandle, "string", Address )
end

function CInputOutput:PawnGUID(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnGUID_offset )
end

function CInputOutput:PawnType(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnType_offset )
end

function CInputOutput:PawnIsAlive(Address)
	return process.read(self.procHandle, "uint", Address + addresses.charAlive_offset )
end

function CInputOutput:PawnIsFading(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnFading_offset )
end

function CInputOutput:PawnHP(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnHP_offset )
end

function CInputOutput:PawnMaxHP(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnMaxHP_offset )
end

function CInputOutput:PawnLastHP(Address)
	return process.read(self.procHandle, "uint", Address + addresses.pawnLastHP_offset )
end

function CInputOutput:PawnClass(select, Address)
	local class;
	if( select == 1 )then
		class = process.read(self.procHandle, "uint", Address + addresses.pawnClass1_offset )
	elseif( select == 2 )then
		class = process.read(self.procHandle, "uint", Address + addresses.pawnClass2_offset )
	elseif( select == 3 )then
		class = process.read(self.procHandle, "uint", Address + addresses.pawnClass3_offset )
	else
		error("not a class index for: "..select.."");
	end
	return class;
end

function CInputOutput:PawnEnergy(select, Address)
	local energy;
	if( select == 1 )then
		energy = process.read(self.procHandle, "int", Address + addresses.pawnMP_offset )
	elseif( select == 2)then
		energy = process.read(self.procHandle, "int", Address + addresses.pawnMP2_offset )
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CInputOutput:PawnMaxEnergy(select, Address)
	local energy;
	if( select == 1 )then
		energy = process.read(self.procHandle, "int", Address + addresses.pawnMaxMP_offset )
	elseif( select == 2)then
		energy = process.read(self.procHandle, "int", Address + addresses.pawnMaxMP2_offset )
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CInputOutput:PawnBuffStartEnde(Address)
	local start = process.read(self.procHandle, "uint", Address +  addresses.pawnBuffsStart_offset );
	local ende  = process.read(self.procHandle, "uint", Address +  addresses.pawnBuffsEnd_offset );
	return start , ende;
end

function CInputOutput:PawnBuffID(i, Address)
	return = process.read(self.procHandle, "uint", Address +  i + addresses.pawnBuffId_offset );
end

function CInputOutput:PawnBuffTimeLeft(i , Address)
	return = process.read(self.procHandle, "float", Address + i + addresses.pawnBuffTimeLeft_offset );
end

function CInputOutput:PawnBuffLevel(i , Address)
	return = process.read(self.procHandle, "float", Address + i + addresses.pawnBuffLevel_offset );
end

function CInputOutput:PawnLootable(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnLootable_offset )
end

function CInputOutput:PawnHarvesting(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnHarvesting_offset )~=0
end

function CInputOutput:PawnCasting(Address)
	return process.read(self.procHandle, "int", Address + addresses.pawnCasting_offset )~=0
end

function CInputOutput:PawnLevel(select, Address)
	local level;
	if( select == 1 )then
		level = process.read(self.procHandle, "uint", Address + addresses.pawnLevel_offset )
	elseif( select == 2 )then
		level = process.read(self.procHandle, "uint", Address + addresses.pawnLevel2_offset )
	elseif( select == 3 )then
		level = process.read(self.procHandle, "uint", Address + addresses.pawnLevel3_offset )
	else
		error("not a level index for: "..select.."");
	end
	return level;
end

function CInputOutput:PawnTargetPtr(Address)
	return process.read(self.procHandle, "uint", Address +  addresses.pawnTargetPtr_offset ) or 0
end
-- again double
function CInputOutput:PawnPosition(select, Address)
	
	if(string.lower(select) == "x" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnX_offset );
	elseif string.lower(select) == "y" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnY_offset );
	elseif string.lower(select) == "z" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnZ_offset );
	end
	error("not specific coordinate type");
	
end

function CInputOutput:PawnDirection(select, Address)
	
	if(string.lower(select) == "x" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnDirXUVec_offset );
	elseif string.lower(select) == "z" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnDirZUVec_offset );
	elseif string.lower(select) == "y" )then
		return process.read(self.procHandle, "float", Address + addresses.pawnDirYUVec_offset );
	end
	error("not specific direction  type");

end

function CInputOutput:PawnSwimming(Address)
	return process.readPtr(self.procHandle, "byte", Address + addresses.pawnSwim_offset1, addresses.pawnSwim_offset2 );
end

function CInputOutput:PawnIsPet(Address)
	return process.read(self.procHandle, "uint", Address +  addresses.pawnIsPet_offset )
end

function CInputOutput:PawnSpeed(Address)
	return process.read(self.procHandle, "float", Address + addresses.pawnSpeed_offset )
end

function CInputOutput:PawnIconBase(Address)
	return process.readPtr(self.procHandle, "uint", Address + addresses.partyIconList_base, addresses.partyIconList_offset);
end
function CInputOutput:PawnIconRead(Address)
	return process.read(self.procHandle, "int", Address)
end