CAbstractInputOutput = class(CBaseObject,
	function (self, procHandle , hwnd)
		self.procHandle = procHandle;
		self.hwnd = hwnd;
	end
);

function CAbstractInputOutput:read(Handle, type, Address  )
	local result = nil;
	local counter = 1;
	local limit = 5;

	repeat
		result = process.read(Handle, type, Address)
		counter = counter + 1
	until counter >= limit or result ~= nil

	return result;
end

function CAbstractInputOutput:readPtr(Handle, type, Address, offset  )
	local result = nil;
	local counter = 1;
	local limit = 5;

	repeat
		result = process.readPtr(Handle, type, Address, offset)
		counter = counter + 1
	until counter >= limit or result ~= nil

	return result;
end
function CAbstractInputOutput:debug(test_value, name,debug_flag, extra_message)
	--TODO put the infos into the logger in any case
	if not debug_flag then
		debug_flag = 0;
	end
	if( settings.options.DEBUGGING and not( debug_flag == 1)) then
		if( not test_value ) then
			if( not extra_message)then
				error("Error in memory  writing or reading function:"..name.."", 2);
			else
				error("Error in memory  writing or reading function:"..name.." "..extra_message.."", 2);
			end
		else
			return TestValue;
		end
	else
		return TestValue;
	end

end
-- objects
function CAbstractInputOutput:ObjectId(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnId_offset ),debug.getinfo(1, "n").name,1) or 0;
end

function CAbstractInputOutput:ObjectType(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnType_offset ) ,debug.getinfo(1, "n").name,1) or -1;
end

function CAbstractInputOutput:ObjectNamePtr(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnName_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:ObjectName(visitor)
	return self:debug(self:read(self.procHandle, "string", visitor:getAddress() ),debug.getinfo(1, "n").name,1);
end

function CAbstractInputOutput:ObjectPosition(select, visitor)

	if(string.lower(select) == "x" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnX_offset ),debug.getinfo(1, "n").name,1)  or 0;
	elseif (string.lower(select) == "y" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnY_offset ) ,debug.getinfo(1, "n").name,1) or 0;
	elseif (string.lower(select) == "z" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnZ_offset ) ,debug.getinfo(1, "n").name,1) or 0;
	end
	error("not specific coordinate type");
end

-- object lists
function CAbstractInputOutput:ObjectListSize(visitor)
	return self:debug(self:read(self.procHandle, "int", addresses.staticTableSize ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:ObjectListPtr(mult)
	-- 4 = 4 byte = 32-bit pointer
	return self:debug(self:readPtr(self.procHandle, "uint", addresses.staticTableSize,mult * 4 ),debug.getinfo(1, "n").name,1)
end
-- pawns
function CAbstractInputOutput:PawnId(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnId_offset) ,debug.getinfo(1, "n").name,1) or 0
end

function CAbstractInputOutput:PawnRace(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnRace_offsett),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnAttackable(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnAttackable_offset),debug.getinfo(1, "n").name,1)
end
-- same as object but if somebody use with another game maybe it is diffrent
function CAbstractInputOutput:PawnNamePtr(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnName_offset ),debug.getinfo(1, "n").name,1)
end
-- again same as object and same reason to let it be
function CAbstractInputOutput:PawnName(visitor)
	return self:debug(self:read(self.procHandle, "string", visitor:getAddress() ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnGUID(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnGUID_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnType(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnType_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnIsAlive(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.charAlive_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnIsFading(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnFading_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnHP(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnHP_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnMaxHP(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxHP_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnLastHP(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLastHP_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnClass(select, visitor)
	local class;
	if( select == 1 )then
		class = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass1_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 2 )then
		class = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass2_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 3 )then
		class = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnClass3_offset ),debug.getinfo(1, "n").name,1)
	else
		error("not a class index for: "..select.."");
	end
	return class;
end

function CAbstractInputOutput:PawnEnergy(select, visitor)
	local energy;
	if( select == 1 )then
		energy = self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMP_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 2)then
		energy = self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMP2_offset ),debug.getinfo(1, "n").name,1)
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CAbstractInputOutput:PawnMaxEnergy(select, visitor)
	local energy;
	if( select == 1 )then
		energy = self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxMP_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 2)then
		energy = self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnMaxMP2_offset ),debug.getinfo(1, "n").name,1)
	else
		error("not a energy index for: "..select.."");
	end
	return energy;
end

function CAbstractInputOutput:PawnBuffStartEnde(visitor)
	local start = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnBuffsStart_offset ),debug.getinfo(1, "n").name,1)
	local ende  = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnBuffsEnd_offset ),debug.getinfo(1, "n").name,1)
	return start , ende;
end

function CAbstractInputOutput:PawnBuffID(i, visitor)
	return  self:debug(self:read(self.procHandle, "uint", visitor:getAddress() +  i + addresses.pawnBuffId_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnBuffTimeLeft(i , visitor)
	return  self:debug(self:read(self.procHandle, "float", visitor:getAddress() + i + addresses.pawnBuffTimeLeft_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnBuffLevel(i , visitor)
	return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + i + addresses.pawnBuffLevel_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnLootable(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnLootable_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnHarvesting(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnHarvesting_offset ),debug.getinfo(1, "n").name,1)~=0
end

function CAbstractInputOutput:PawnCasting(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress() + addresses.pawnCasting_offset ),debug.getinfo(1, "n").name,1)~=0
end

function CAbstractInputOutput:PawnLevel(select, visitor)
	local level;
	if( select == 1 )then
		level = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 2 )then
		level = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel2_offset ),debug.getinfo(1, "n").name,1)
	elseif( select == 3 )then
		level = self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.pawnLevel3_offset ),debug.getinfo(1, "n").name,1)
	else
		error("not a level index for: "..select.."");
	end
	return level;
end

function CAbstractInputOutput:PawnTargetPtr(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnTargetPtr_offset ),debug.getinfo(1, "n").name,1) or 0;
end
-- again double
function CAbstractInputOutput:PawnPosition(select, visitor)

	if(string.lower(select) == "x" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnX_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "y" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnY_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "z" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnZ_offset ),debug.getinfo(1, "n").name,1)
	end
	error("not specific coordinate type: "..select.."");

end

function CAbstractInputOutput:PawnDirection(select, visitor)

	if(string.lower(select) == "x" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirXUVec_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "z" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirZUVec_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "y" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirYUVec_offset ),debug.getinfo(1, "n").name,1)
	end
	error("not specific direction type: "..select.."");

end
function CAbstractInputOutput:WritePawnDirection(select, visitor, data, shift)
	if not shift then
		shift = 0;
	end
	if(string.lower(select) == "x" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirXUVec_offset, data )
	elseif (string.lower(select) == "z" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.pawnDirZUVec_offset, data )
	elseif (string.lower(select) == "y" )then
		return process.write(self.procHandle, "float",  visitor:getAddress() + addresses.pawnDirYUVec_offset, data )
	else
		error("not specific direction  type: "..select.."");
	end

end
function CAbstractInputOutput:CameraDirection(select, visitor)

	if(string.lower(select) == "x" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camXUVec_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "z" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camZUVec_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "y" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camYUVec_offset ),debug.getinfo(1, "n").name,1)
	end
	error("not specific direction  type: "..select.."");

end
function CAbstractInputOutput:CameraPosition(select, visitor)
	--TODO: move cam to addresse space
	if(string.lower(select) == "x" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camX_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "y" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camY_offset ),debug.getinfo(1, "n").name,1)
	elseif (string.lower(select) == "z" )then
		return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.camZ_offset ),debug.getinfo(1, "n").name,1)
	end
	error("not specific coordinate type");

end
function CAbstractInputOutput:WriteCameraDirection(data, select, visitor)

	if(string.lower(select) == "x" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camXUVec_offset, data )
	elseif (string.lower(select) == "z" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camZUVec_offset, data )
	elseif (string.lower(select) == "y" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camYUVec_offset, data )
	end
	error("not specific direction  type: "..select.."");


end
function CAbstractInputOutput:WriteCameraPosition(data, select, visitor)
	--TODO: move cam to addresse space
	if(string.lower(select) == "x" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camX_offset, data);
	elseif (string.lower(select) == "y" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camY_offset, data);
	elseif (string.lower(select) == "z" )then
		return process.write(self.procHandle, "float", visitor:getAddress() + addresses.camZ_offset, data);
	end
	error("not specific coordinate type: "..select.."");

end
function CAbstractInputOutput:PawnSwimming(visitor)
	return self:debug(self:readPtr(self.procHandle, "byte", visitor:getAddress() + addresses.pawnSwim_offset1, addresses.pawnSwim_offset2 ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnIsPet(visitor)
	return self:debug(self:read(self.procHandle, "uint", visitor:getAddress() +  addresses.pawnIsPet_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnSpeed(visitor)
	return self:debug(self:read(self.procHandle, "float", visitor:getAddress() + addresses.pawnSpeed_offset ),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PawnIconBase(visitor)
	return self:debug(self:readPtr(self.procHandle, "uint", visitor:getAddress() + addresses.partyIconList_base, addresses.partyIconList_offset),debug.getinfo(1, "n").name,1)
end
function CAbstractInputOutput:PawnIconRead(visitor)
	return self:debug(self:read(self.procHandle, "int", visitor:getAddress()),debug.getinfo(1, "n").name,1)
end

function CAbstractInputOutput:PressKey(visitor, key1, key2)

	if( not key2)then
		keyboard.virtualPress(self.hwnd, key1, true);
	else
		keyboard.virtualHold(self.hwnd, key1);
	end

	if (key2)then
		keyboard.virtualHold(self.hwnd, key2);
		keyboard.virtualRelease(self.hwnd, key1);
		keyboard.virtualRelease(self.hwnd, key2);
	end
end

function CAbstractInputOutput:PressHold(visitor, key1, key2)

	keyboard.virtualHold(self.hwnd, key1);

	if (key2)then
		keyboard.virtualHold(self.hwnd, key2);

	end
end

function CAbstractInputOutput:PressRelease(visitor, key1, key2)

	keyboard.virtualRelease(self.hwnd, key1);

	if (key2)then
		keyboard.virtualRelease(self.hwnd, key2);
	end
end
function CAbstractInputOutput:WriteText(visitor,text)

	keyboard.keyboard.virtualType(self.hwnd, text);

end

function CAbstractInputOutput:MountBase(visitor)
	return  self:debug(self:read(self.procHandle, "uint", visitor:getAddress() + addresses.charPtrMounted_offset ),debug.getinfo(1, "n").name,1)
end
